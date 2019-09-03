// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include <lzws/buffer.h>
#include <lzws/compressor/common.h>
#include <lzws/compressor/header.h>
#include <lzws/compressor/main.h>
#include <lzws/compressor/state.h>

#include "ruby.h"

#include "lzws_ext/error.h"
#include "lzws_ext/macro.h"
#include "lzws_ext/option.h"
#include "lzws_ext/stream/compressor.h"

static void free_compressor(lzws_ext_compressor_t* compressor_ptr)
{
  lzws_compressor_state_t* state_ptr = compressor_ptr->state_ptr;
  if (state_ptr != NULL) {
    lzws_compressor_free_state(state_ptr);
  }

  uint8_t* destination_buffer = compressor_ptr->destination_buffer;
  if (destination_buffer != NULL) {
    free(destination_buffer);
  }

  free(compressor_ptr);
}

VALUE lzws_ext_allocate_compressor(VALUE klass)
{
  lzws_ext_compressor_t* compressor_ptr;

  VALUE self = Data_Make_Struct(klass, lzws_ext_compressor_t, NULL, free_compressor, compressor_ptr);

  compressor_ptr->state_ptr                           = NULL;
  compressor_ptr->destination_buffer                  = NULL;
  compressor_ptr->destination_buffer_length           = 0;
  compressor_ptr->remaining_destination_buffer        = NULL;
  compressor_ptr->remaining_destination_buffer_length = 0;

  return self;
}

#define GET_COMPRESSOR()                 \
  lzws_ext_compressor_t* compressor_ptr; \
  Data_Get_Struct(self, lzws_ext_compressor_t, compressor_ptr);

VALUE lzws_ext_initialize_compressor(VALUE self, VALUE options)
{
  GET_COMPRESSOR();
  LZWS_EXT_GET_COMPRESSOR_OPTIONS(options);
  LZWS_EXT_UNUSED_VARIABLE(without_magic_header);

  lzws_compressor_state_t* state_ptr;

  lzws_result_t result = lzws_compressor_get_initial_state(
    &state_ptr,
    max_code_bit_length, block_mode, msb, unaligned_bit_groups, quiet);

  if (result == LZWS_COMPRESSOR_ALLOCATE_FAILED) {
    lzws_ext_raise_error("AllocateError", "allocate error");
  }
  else if (result == LZWS_COMPRESSOR_INVALID_MAX_CODE_BIT_LENGTH) {
    lzws_ext_raise_error("ValidateError", "validate error");
  }
  else if (result != 0) {
    lzws_ext_raise_error("UnexpectedError", "unexpected error");
  }

  uint8_t* buffer;

  result = lzws_create_buffer_for_compressor(&buffer, &buffer_length, quiet);
  if (result != 0) {
    lzws_compressor_free_state(state_ptr);
    lzws_ext_raise_error("AllocateError", "allocate error");
  }

  compressor_ptr->state_ptr                           = state_ptr;
  compressor_ptr->destination_buffer                  = buffer;
  compressor_ptr->destination_buffer_length           = buffer_length;
  compressor_ptr->remaining_destination_buffer        = buffer;
  compressor_ptr->remaining_destination_buffer_length = buffer_length;

  return Qnil;
}

#define DO_NOT_USE_AFTER_CLOSE()                                                         \
  if (compressor_ptr->state_ptr == NULL || compressor_ptr->destination_buffer == NULL) { \
    lzws_ext_raise_error("UsedAfterCloseError", "compressor used after closed");         \
  }

VALUE lzws_ext_compressor_write_magic_header(VALUE self)
{
  GET_COMPRESSOR();
  DO_NOT_USE_AFTER_CLOSE();

  lzws_result_t result = lzws_compressor_write_magic_header(
    &compressor_ptr->remaining_destination_buffer,
    &compressor_ptr->remaining_destination_buffer_length);

  if (result == 0) {
    return Qfalse;
  }
  else if (result == LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION) {
    return Qtrue;
  }
  else {
    lzws_ext_raise_error("UnexpectedError", "unexpected error");
  }
}

#define GET_SOURCE_STRING()                        \
  Check_Type(source, T_STRING);                    \
                                                   \
  const char* source_data   = RSTRING_PTR(source); \
  size_t      source_length = RSTRING_LEN(source);

VALUE lzws_ext_compress(VALUE self, VALUE source)
{
  GET_COMPRESSOR();
  DO_NOT_USE_AFTER_CLOSE();
  GET_SOURCE_STRING();

  uint8_t* remaining_source_data   = (uint8_t*)source_data;
  size_t   remaining_source_length = source_length;

  lzws_result_t result = lzws_compress(
    compressor_ptr->state_ptr,
    &remaining_source_data,
    &remaining_source_length,
    &compressor_ptr->remaining_destination_buffer,
    &compressor_ptr->remaining_destination_buffer_length);

  VALUE bytes_written = INT2NUM(source_length - remaining_source_length);

  VALUE needs_more_destination;
  if (result == LZWS_COMPRESSOR_NEEDS_MORE_SOURCE) {
    needs_more_destination = Qfalse;
  }
  else if (result == LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION) {
    needs_more_destination = Qtrue;
  }
  else {
    lzws_ext_raise_error("UnexpectedError", "unexpected error");
  }

  return rb_ary_new_from_args(2, bytes_written, needs_more_destination);
}

VALUE lzws_ext_finish_compressor(VALUE self)
{
  GET_COMPRESSOR();
  DO_NOT_USE_AFTER_CLOSE();

  lzws_result_t result = lzws_finish_compressor(
    compressor_ptr->state_ptr,
    &compressor_ptr->remaining_destination_buffer,
    &compressor_ptr->remaining_destination_buffer_length);

  if (result == 0) {
    return Qfalse;
  }
  else if (result == LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION) {
    return Qtrue;
  }
  else {
    lzws_ext_raise_error("UnexpectedError", "unexpected error");
  }
}

VALUE lzws_ext_compressor_read_result(VALUE self)
{
  GET_COMPRESSOR();
  DO_NOT_USE_AFTER_CLOSE();

  uint8_t* destination_buffer                  = compressor_ptr->destination_buffer;
  size_t   destination_buffer_length           = compressor_ptr->destination_buffer_length;
  size_t   remaining_destination_buffer_length = compressor_ptr->remaining_destination_buffer_length;

  const char* result_data   = (const char*)destination_buffer;
  size_t      result_length = destination_buffer_length - remaining_destination_buffer_length;

  VALUE result = rb_str_new(result_data, result_length);

  compressor_ptr->remaining_destination_buffer        = destination_buffer;
  compressor_ptr->remaining_destination_buffer_length = destination_buffer_length;

  return result;
}

VALUE lzws_ext_compressor_close(VALUE self)
{
  GET_COMPRESSOR();
  DO_NOT_USE_AFTER_CLOSE();

  lzws_compressor_state_t* state_ptr = compressor_ptr->state_ptr;
  if (state_ptr != NULL) {
    lzws_compressor_free_state(state_ptr);

    compressor_ptr->state_ptr = NULL;
  }

  uint8_t* destination_buffer = compressor_ptr->destination_buffer;
  if (destination_buffer != NULL) {
    free(destination_buffer);

    compressor_ptr->destination_buffer = NULL;
  }

  // It is possible to keep "destination_buffer_length", "remaining_destination_buffer"
  //   and "remaining_destination_buffer_length" as is.

  return Qnil;
}

void lzws_ext_compressor_exports(VALUE root_module)
{
  VALUE stream = rb_define_module_under(root_module, "Stream");

  VALUE compressor = rb_define_class_under(stream, "NativeCompressor", rb_cObject);
  rb_define_alloc_func(compressor, lzws_ext_allocate_compressor);
  rb_define_method(compressor, "initialize", lzws_ext_initialize_compressor, 1);
  rb_define_method(compressor, "write_magic_header", lzws_ext_compressor_write_magic_header, 0);
  rb_define_method(compressor, "write", lzws_ext_compress, 1);
  rb_define_method(compressor, "finish", lzws_ext_finish_compressor, 0);
  rb_define_method(compressor, "read_result", lzws_ext_compressor_read_result, 0);
  rb_define_method(compressor, "close", lzws_ext_compressor_close, 0);
}
