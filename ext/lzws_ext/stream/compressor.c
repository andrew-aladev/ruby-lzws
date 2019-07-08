// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include <lzws/buffer.h>
#include <lzws/compressor/common.h>
#include <lzws/compressor/header.h>
#include <lzws/compressor/main.h>
#include <lzws/compressor/state.h>

#include "lzws_ext/error.h"
#include "lzws_ext/macro.h"
#include "lzws_ext/option.h"
#include "lzws_ext/stream/compressor.h"
#include "ruby.h"

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

#define GET_COMPRESSOR(self)             \
  lzws_ext_compressor_t* compressor_ptr; \
  Data_Get_Struct(self, lzws_ext_compressor_t, compressor_ptr);

VALUE lzws_ext_initialize_compressor(VALUE self, VALUE options)
{
  GET_COMPRESSOR(self);
  LZWS_EXT_GET_COMPRESSOR_OPTIONS(options);
  LZWS_EXT_UNUSED_VARIABLE(without_magic_header);

  lzws_compressor_state_t* compressor_state_ptr;

  lzws_result_t result = lzws_compressor_get_initial_state(
    &compressor_state_ptr,
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

  compressor_ptr->state_ptr = compressor_state_ptr;

  // -----

  uint8_t* destination_buffer;
  size_t   destination_buffer_length = buffer_length;

  result = lzws_create_buffer_for_compressor(&destination_buffer, &destination_buffer_length, quiet);
  if (result != 0) {
    lzws_ext_raise_error("AllocateError", "allocate error");
  }

  compressor_ptr->destination_buffer                  = destination_buffer;
  compressor_ptr->destination_buffer_length           = destination_buffer_length;
  compressor_ptr->remaining_destination_buffer        = destination_buffer;
  compressor_ptr->remaining_destination_buffer_length = destination_buffer_length;

  return Qnil;
}

#define DO_NOT_USE_AFTER_CLOSE(compressor_ptr)                                           \
  if (compressor_ptr->state_ptr == NULL || compressor_ptr->destination_buffer == NULL) { \
    lzws_ext_raise_error("UsedAfterCloseError", "compressor used after closed");         \
  }

VALUE lzws_ext_compressor_write_magic_header(VALUE self)
{
  GET_COMPRESSOR(self);
  DO_NOT_USE_AFTER_CLOSE(compressor_ptr);

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

#define GET_STRING(source)                         \
  Check_Type(source, T_STRING);                    \
                                                   \
  const char* source_data   = RSTRING_PTR(source); \
  size_t      source_length = RSTRING_LEN(source);

VALUE lzws_ext_compress(VALUE self, VALUE source)
{
  GET_COMPRESSOR(self);
  DO_NOT_USE_AFTER_CLOSE(compressor_ptr);
  GET_STRING(source);

  uint8_t* remaining_source_data   = (uint8_t*)source_data;
  size_t   remaining_source_length = source_length;

  lzws_result_t result = lzws_compress(
    compressor_ptr->state_ptr,
    &remaining_source_data,
    &remaining_source_length,
    &compressor_ptr->remaining_destination_buffer,
    &compressor_ptr->remaining_destination_buffer_length);

  VALUE bytes_written = INT2NUM(source_length - remaining_source_length);

  if (result == LZWS_COMPRESSOR_NEEDS_MORE_SOURCE) {
    return rb_ary_new_from_args(2, bytes_written, Qfalse);
  }
  else if (result == LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION) {
    return rb_ary_new_from_args(2, bytes_written, Qtrue);
  }
  else {
    lzws_ext_raise_error("UnexpectedError", "unexpected error");
  }
}

VALUE lzws_ext_flush_compressor(VALUE self)
{
  GET_COMPRESSOR(self);
  DO_NOT_USE_AFTER_CLOSE(compressor_ptr);

  lzws_result_t result = lzws_flush_compressor(
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
  GET_COMPRESSOR(self);
  DO_NOT_USE_AFTER_CLOSE(compressor_ptr);

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
  GET_COMPRESSOR(self);
  DO_NOT_USE_AFTER_CLOSE(compressor_ptr);

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
