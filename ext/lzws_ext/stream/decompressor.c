// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/stream/decompressor.h"

#include <lzws/buffer.h>
#include <lzws/decompressor/main.h>

#include "lzws_ext/error.h"
#include "lzws_ext/gvl.h"
#include "lzws_ext/option.h"

// -- initialization --

static void free_decompressor(lzws_ext_decompressor_t* decompressor_ptr)
{
  lzws_decompressor_state_t* state_ptr = decompressor_ptr->state_ptr;
  if (state_ptr != NULL) {
    lzws_decompressor_free_state(state_ptr);
  }

  lzws_ext_byte_t* destination_buffer = decompressor_ptr->destination_buffer;
  if (destination_buffer != NULL) {
    free(destination_buffer);
  }

  free(decompressor_ptr);
}

VALUE lzws_ext_allocate_decompressor(VALUE klass)
{
  lzws_ext_decompressor_t* decompressor_ptr;
  VALUE self = Data_Make_Struct(klass, lzws_ext_decompressor_t, NULL, free_decompressor, decompressor_ptr);

  decompressor_ptr->state_ptr                           = NULL;
  decompressor_ptr->destination_buffer                  = NULL;
  decompressor_ptr->destination_buffer_length           = 0;
  decompressor_ptr->remaining_destination_buffer        = NULL;
  decompressor_ptr->remaining_destination_buffer_length = 0;

  return self;
}

#define GET_DECOMPRESSOR(self)               \
  lzws_ext_decompressor_t* decompressor_ptr; \
  Data_Get_Struct(self, lzws_ext_decompressor_t, decompressor_ptr);

VALUE lzws_ext_initialize_decompressor(VALUE self, VALUE options)
{
  GET_DECOMPRESSOR(self);
  Check_Type(options, T_HASH);
  LZWS_EXT_GET_SIZE_OPTION(options, destination_buffer_length);
  LZWS_EXT_GET_BOOL_OPTION(options, gvl);
  LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options);

  lzws_decompressor_state_t* state_ptr;

  lzws_result_t result = lzws_decompressor_get_initial_state(&state_ptr, &decompressor_options);
  if (result != 0) {
    switch (result) {
      case LZWS_DECOMPRESSOR_ALLOCATE_FAILED:
        lzws_ext_raise_error(LZWS_EXT_ERROR_ALLOCATE_FAILED);
      default:
        lzws_ext_raise_error(LZWS_EXT_ERROR_UNEXPECTED);
    }
  }

  lzws_ext_byte_t* destination_buffer;

  result = lzws_create_destination_buffer_for_decompressor(
    &destination_buffer, &destination_buffer_length, decompressor_options.quiet);

  if (result != 0) {
    lzws_decompressor_free_state(state_ptr);
    lzws_ext_raise_error(LZWS_EXT_ERROR_ALLOCATE_FAILED);
  }

  decompressor_ptr->state_ptr                           = state_ptr;
  decompressor_ptr->destination_buffer                  = destination_buffer;
  decompressor_ptr->destination_buffer_length           = destination_buffer_length;
  decompressor_ptr->remaining_destination_buffer        = destination_buffer;
  decompressor_ptr->remaining_destination_buffer_length = destination_buffer_length;
  decompressor_ptr->gvl                                 = gvl;

  return Qnil;
}

// -- decompress --

#define DO_NOT_USE_AFTER_CLOSE(decompressor_ptr)                                             \
  if (decompressor_ptr->state_ptr == NULL || decompressor_ptr->destination_buffer == NULL) { \
    lzws_ext_raise_error(LZWS_EXT_ERROR_USED_AFTER_CLOSE);                                   \
  }

typedef struct
{
  lzws_ext_decompressor_t* decompressor_ptr;
  lzws_ext_byte_t*         remaining_source;
  size_t*                  remaining_source_length_ptr;
  lzws_result_t            result;
} decompress_args_t;

static inline void* decompress_wrapper(void* data)
{
  decompress_args_t*       args             = data;
  lzws_ext_decompressor_t* decompressor_ptr = args->decompressor_ptr;

  args->result = lzws_decompress(
    decompressor_ptr->state_ptr,
    &args->remaining_source,
    args->remaining_source_length_ptr,
    &decompressor_ptr->remaining_destination_buffer,
    &decompressor_ptr->remaining_destination_buffer_length);

  return NULL;
}

VALUE lzws_ext_decompress(VALUE self, VALUE source_value)
{
  GET_DECOMPRESSOR(self);
  DO_NOT_USE_AFTER_CLOSE(decompressor_ptr);
  Check_Type(source_value, T_STRING);

  const char*      source                  = RSTRING_PTR(source_value);
  size_t           source_length           = RSTRING_LEN(source_value);
  lzws_ext_byte_t* remaining_source        = (lzws_ext_byte_t*) source;
  size_t           remaining_source_length = source_length;

  decompress_args_t args = {
    .decompressor_ptr            = decompressor_ptr,
    .remaining_source            = remaining_source,
    .remaining_source_length_ptr = &remaining_source_length};

  LZWS_EXT_GVL_WRAP(decompressor_ptr->gvl, decompress_wrapper, &args);
  if (args.result != 0 && args.result != LZWS_DECOMPRESSOR_NEEDS_MORE_DESTINATION) {
    switch (args.result) {
      case LZWS_DECOMPRESSOR_INVALID_MAGIC_HEADER:
      case LZWS_DECOMPRESSOR_INVALID_MAX_CODE_BIT_LENGTH:
        lzws_ext_raise_error(LZWS_EXT_ERROR_VALIDATE_FAILED);
      case LZWS_DECOMPRESSOR_CORRUPTED_SOURCE:
        lzws_ext_raise_error(LZWS_EXT_ERROR_DECOMPRESSOR_CORRUPTED_SOURCE);
      default:
        lzws_ext_raise_error(LZWS_EXT_ERROR_UNEXPECTED);
    }
  }

  VALUE bytes_read             = SIZET2NUM(source_length - remaining_source_length);
  VALUE needs_more_destination = args.result == LZWS_DECOMPRESSOR_NEEDS_MORE_DESTINATION ? Qtrue : Qfalse;

  return rb_ary_new_from_args(2, bytes_read, needs_more_destination);
}

// -- other --

VALUE lzws_ext_decompressor_read_result(VALUE self)
{
  GET_DECOMPRESSOR(self);
  DO_NOT_USE_AFTER_CLOSE(decompressor_ptr);

  lzws_ext_byte_t* destination_buffer                  = decompressor_ptr->destination_buffer;
  size_t           destination_buffer_length           = decompressor_ptr->destination_buffer_length;
  size_t           remaining_destination_buffer_length = decompressor_ptr->remaining_destination_buffer_length;

  const char* result        = (const char*) destination_buffer;
  size_t      result_length = destination_buffer_length - remaining_destination_buffer_length;
  VALUE       result_value  = rb_str_new(result, result_length);

  decompressor_ptr->remaining_destination_buffer        = destination_buffer;
  decompressor_ptr->remaining_destination_buffer_length = destination_buffer_length;

  return result_value;
}

// -- cleanup --

VALUE lzws_ext_decompressor_close(VALUE self)
{
  GET_DECOMPRESSOR(self);
  DO_NOT_USE_AFTER_CLOSE(decompressor_ptr);

  lzws_decompressor_state_t* state_ptr = decompressor_ptr->state_ptr;
  if (state_ptr != NULL) {
    lzws_decompressor_free_state(state_ptr);

    decompressor_ptr->state_ptr = NULL;
  }

  lzws_ext_byte_t* destination_buffer = decompressor_ptr->destination_buffer;
  if (destination_buffer != NULL) {
    free(destination_buffer);

    decompressor_ptr->destination_buffer = NULL;
  }

  // It is possible to keep "destination_buffer_length", "remaining_destination_buffer"
  //   and "remaining_destination_buffer_length" as is.

  return Qnil;
}

// -- exports --

void lzws_ext_decompressor_exports(VALUE root_module)
{
  VALUE module = rb_define_module_under(root_module, "Stream");

  VALUE decompressor = rb_define_class_under(module, "NativeDecompressor", rb_cObject);

  rb_define_alloc_func(decompressor, lzws_ext_allocate_decompressor);
  rb_define_method(decompressor, "initialize", lzws_ext_initialize_decompressor, 1);
  rb_define_method(decompressor, "read", lzws_ext_decompress, 1);
  rb_define_method(decompressor, "read_result", lzws_ext_decompressor_read_result, 0);
  rb_define_method(decompressor, "close", lzws_ext_decompressor_close, 0);
}
