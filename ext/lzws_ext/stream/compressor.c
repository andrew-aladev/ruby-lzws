// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/stream/compressor.h"

#include <lzws/buffer.h>
#include <lzws/compressor/main.h>

#include "lzws_ext/error.h"
#include "lzws_ext/gvl.h"
#include "lzws_ext/option.h"

// -- initialization --

static void free_compressor(lzws_ext_compressor_t* compressor_ptr)
{
  lzws_compressor_state_t* state_ptr = compressor_ptr->state_ptr;
  if (state_ptr != NULL) {
    lzws_compressor_free_state(state_ptr);
  }

  lzws_ext_byte_t* destination_buffer = compressor_ptr->destination_buffer;
  if (destination_buffer != NULL) {
    free(destination_buffer);
  }

  free(compressor_ptr);
}

VALUE lzws_ext_allocate_compressor(VALUE klass)
{
  lzws_ext_compressor_t* compressor_ptr;
  VALUE                  self = Data_Make_Struct(klass, lzws_ext_compressor_t, NULL, free_compressor, compressor_ptr);

  compressor_ptr->state_ptr                           = NULL;
  compressor_ptr->destination_buffer                  = NULL;
  compressor_ptr->destination_buffer_length           = 0;
  compressor_ptr->remaining_destination_buffer        = NULL;
  compressor_ptr->remaining_destination_buffer_length = 0;
  compressor_ptr->gvl                                 = false;

  return self;
}

#define GET_COMPRESSOR(self)             \
  lzws_ext_compressor_t* compressor_ptr; \
  Data_Get_Struct(self, lzws_ext_compressor_t, compressor_ptr);

VALUE lzws_ext_initialize_compressor(VALUE self, VALUE options)
{
  GET_COMPRESSOR(self);
  Check_Type(options, T_HASH);
  LZWS_EXT_GET_SIZE_OPTION(options, destination_buffer_length);
  LZWS_EXT_GET_BOOL_OPTION(options, gvl);
  LZWS_EXT_GET_COMPRESSOR_OPTIONS(options);

  lzws_compressor_state_t* state_ptr;

  lzws_result_t result = lzws_compressor_get_initial_state(&state_ptr, &compressor_options);
  if (result != 0) {
    switch (result) {
      case LZWS_COMPRESSOR_ALLOCATE_FAILED:
        lzws_ext_raise_error(LZWS_EXT_ERROR_ALLOCATE_FAILED);
      case LZWS_COMPRESSOR_INVALID_MAX_CODE_BIT_LENGTH:
        lzws_ext_raise_error(LZWS_EXT_ERROR_VALIDATE_FAILED);
      default:
        lzws_ext_raise_error(LZWS_EXT_ERROR_UNEXPECTED);
    }
  }

  lzws_ext_byte_t* destination_buffer;

  result = lzws_create_destination_buffer_for_compressor(
    &destination_buffer, &destination_buffer_length, compressor_options.quiet);

  if (result != 0) {
    lzws_compressor_free_state(state_ptr);
    lzws_ext_raise_error(LZWS_EXT_ERROR_ALLOCATE_FAILED);
  }

  compressor_ptr->state_ptr                           = state_ptr;
  compressor_ptr->destination_buffer                  = destination_buffer;
  compressor_ptr->destination_buffer_length           = destination_buffer_length;
  compressor_ptr->remaining_destination_buffer        = destination_buffer;
  compressor_ptr->remaining_destination_buffer_length = destination_buffer_length;
  compressor_ptr->gvl                                 = gvl;

  return Qnil;
}

// -- compress --

#define DO_NOT_USE_AFTER_CLOSE(compressor_ptr)                                           \
  if (compressor_ptr->state_ptr == NULL || compressor_ptr->destination_buffer == NULL) { \
    lzws_ext_raise_error(LZWS_EXT_ERROR_USED_AFTER_CLOSE);                               \
  }

typedef struct
{
  lzws_ext_compressor_t* compressor_ptr;
  lzws_ext_byte_t*       remaining_source;
  size_t*                remaining_source_length_ptr;
  lzws_result_t          result;
} compress_args_t;

static inline void* compress_wrapper(void* data)
{
  compress_args_t*       args           = data;
  lzws_ext_compressor_t* compressor_ptr = args->compressor_ptr;

  args->result = lzws_compress(
    compressor_ptr->state_ptr,
    &args->remaining_source,
    args->remaining_source_length_ptr,
    &compressor_ptr->remaining_destination_buffer,
    &compressor_ptr->remaining_destination_buffer_length);

  return NULL;
}

VALUE lzws_ext_compress(VALUE self, VALUE source_value)
{
  GET_COMPRESSOR(self);
  DO_NOT_USE_AFTER_CLOSE(compressor_ptr);
  Check_Type(source_value, T_STRING);

  const char*      source                  = RSTRING_PTR(source_value);
  size_t           source_length           = RSTRING_LEN(source_value);
  lzws_ext_byte_t* remaining_source        = (lzws_ext_byte_t*) source;
  size_t           remaining_source_length = source_length;

  compress_args_t args = {
    .compressor_ptr              = compressor_ptr,
    .remaining_source            = remaining_source,
    .remaining_source_length_ptr = &remaining_source_length};

  LZWS_EXT_GVL_WRAP(compressor_ptr->gvl, compress_wrapper, &args);
  if (args.result != 0 && args.result != LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION) {
    lzws_ext_raise_error(LZWS_EXT_ERROR_UNEXPECTED);
  }

  VALUE bytes_written          = SIZET2NUM(source_length - remaining_source_length);
  VALUE needs_more_destination = args.result == LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION ? Qtrue : Qfalse;

  return rb_ary_new_from_args(2, bytes_written, needs_more_destination);
}

// -- compressor finish --

typedef struct
{
  lzws_ext_compressor_t* compressor_ptr;
  lzws_result_t          result;
} compressor_finish_args_t;

static inline void* compressor_finish_wrapper(void* data)
{
  compressor_finish_args_t* args           = data;
  lzws_ext_compressor_t*    compressor_ptr = args->compressor_ptr;

  args->result = lzws_compressor_finish(
    compressor_ptr->state_ptr,
    &compressor_ptr->remaining_destination_buffer,
    &compressor_ptr->remaining_destination_buffer_length);

  return NULL;
}

VALUE lzws_ext_compressor_finish(VALUE self)
{
  GET_COMPRESSOR(self);
  DO_NOT_USE_AFTER_CLOSE(compressor_ptr);

  compressor_finish_args_t args = {.compressor_ptr = compressor_ptr};

  LZWS_EXT_GVL_WRAP(compressor_ptr->gvl, compressor_finish_wrapper, &args);
  if (args.result != 0 && args.result != LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION) {
    lzws_ext_raise_error(LZWS_EXT_ERROR_UNEXPECTED);
  }

  return args.result == LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION ? Qtrue : Qfalse;
}

// -- other --

VALUE lzws_ext_compressor_read_result(VALUE self)
{
  GET_COMPRESSOR(self);
  DO_NOT_USE_AFTER_CLOSE(compressor_ptr);

  lzws_ext_byte_t* destination_buffer                  = compressor_ptr->destination_buffer;
  size_t           destination_buffer_length           = compressor_ptr->destination_buffer_length;
  size_t           remaining_destination_buffer_length = compressor_ptr->remaining_destination_buffer_length;

  const char* result        = (const char*) destination_buffer;
  size_t      result_length = destination_buffer_length - remaining_destination_buffer_length;
  VALUE       result_value  = rb_str_new(result, result_length);

  compressor_ptr->remaining_destination_buffer        = destination_buffer;
  compressor_ptr->remaining_destination_buffer_length = destination_buffer_length;

  return result_value;
}

// -- cleanup --

VALUE lzws_ext_compressor_close(VALUE self)
{
  GET_COMPRESSOR(self);
  DO_NOT_USE_AFTER_CLOSE(compressor_ptr);

  lzws_compressor_state_t* state_ptr = compressor_ptr->state_ptr;
  if (state_ptr != NULL) {
    lzws_compressor_free_state(state_ptr);

    compressor_ptr->state_ptr = NULL;
  }

  lzws_ext_byte_t* destination_buffer = compressor_ptr->destination_buffer;
  if (destination_buffer != NULL) {
    free(destination_buffer);

    compressor_ptr->destination_buffer = NULL;
  }

  // It is possible to keep "destination_buffer_length", "remaining_destination_buffer",
  //   "remaining_destination_buffer_length" and "gvl" as is.

  return Qnil;
}

// -- exports --

void lzws_ext_compressor_exports(VALUE root_module)
{
  VALUE module = rb_define_module_under(root_module, "Stream");

  VALUE compressor = rb_define_class_under(module, "NativeCompressor", rb_cObject);

  rb_define_alloc_func(compressor, lzws_ext_allocate_compressor);
  rb_define_method(compressor, "initialize", lzws_ext_initialize_compressor, 1);
  rb_define_method(compressor, "write", lzws_ext_compress, 1);
  rb_define_method(compressor, "finish", lzws_ext_compressor_finish, 0);
  rb_define_method(compressor, "read_result", lzws_ext_compressor_read_result, 0);
  rb_define_method(compressor, "close", lzws_ext_compressor_close, 0);
}
