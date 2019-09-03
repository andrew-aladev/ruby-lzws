// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include <lzws/buffer.h>
#include <lzws/decompressor/common.h>
#include <lzws/decompressor/header.h>
#include <lzws/decompressor/main.h>
#include <lzws/decompressor/state.h>

#include "ruby.h"

#include "lzws_ext/error.h"
#include "lzws_ext/macro.h"
#include "lzws_ext/option.h"
#include "lzws_ext/stream/decompressor.h"

static void free_decompressor(lzws_ext_decompressor_t* decompressor_ptr)
{
  lzws_decompressor_state_t* state_ptr = decompressor_ptr->state_ptr;
  if (state_ptr != NULL) {
    lzws_decompressor_free_state(state_ptr);
  }

  uint8_t* destination_buffer = decompressor_ptr->destination_buffer;
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

#define GET_DECOMPRESSOR()                   \
  lzws_ext_decompressor_t* decompressor_ptr; \
  Data_Get_Struct(self, lzws_ext_decompressor_t, decompressor_ptr);

VALUE lzws_ext_initialize_decompressor(VALUE self, VALUE options)
{
  GET_DECOMPRESSOR();
  LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options);
  LZWS_EXT_UNUSED_VARIABLE(without_magic_header);

  lzws_decompressor_state_t* state_ptr;

  lzws_result_t result = lzws_decompressor_get_initial_state(
    &state_ptr,
    msb, unaligned_bit_groups, quiet);

  if (result == LZWS_DECOMPRESSOR_ALLOCATE_FAILED) {
    lzws_ext_raise_error("AllocateError", "allocate error");
  }
  else if (result != 0) {
    lzws_ext_raise_error("UnexpectedError", "unexpected error");
  }

  uint8_t* buffer;

  result = lzws_create_buffer_for_decompressor(&buffer, &buffer_length, quiet);
  if (result != 0) {
    lzws_decompressor_free_state(state_ptr);
    lzws_ext_raise_error("AllocateError", "allocate error");
  }

  decompressor_ptr->state_ptr                           = state_ptr;
  decompressor_ptr->destination_buffer                  = buffer;
  decompressor_ptr->destination_buffer_length           = buffer_length;
  decompressor_ptr->remaining_destination_buffer        = buffer;
  decompressor_ptr->remaining_destination_buffer_length = buffer_length;

  return Qnil;
}

#define GET_SOURCE_STRING()                        \
  Check_Type(source, T_STRING);                    \
                                                   \
  const char* source_data   = RSTRING_PTR(source); \
  size_t      source_length = RSTRING_LEN(source);

#define DO_NOT_USE_AFTER_CLOSE()                                                             \
  if (decompressor_ptr->state_ptr == NULL || decompressor_ptr->destination_buffer == NULL) { \
    lzws_ext_raise_error("UsedAfterCloseError", "decompressor used after close");            \
  }

VALUE lzws_ext_decompressor_read_magic_header(VALUE self, VALUE source)
{
  GET_DECOMPRESSOR();
  DO_NOT_USE_AFTER_CLOSE();
  GET_SOURCE_STRING();

  uint8_t* remaining_source_data   = (uint8_t*)source_data;
  size_t   remaining_source_length = source_length;

  lzws_result_t result = lzws_decompressor_read_magic_header(
    decompressor_ptr->state_ptr,
    &remaining_source_data,
    &remaining_source_length);

  VALUE bytes_read = INT2NUM(source_length - remaining_source_length);

  if (result == 0 || result == LZWS_DECOMPRESSOR_NEEDS_MORE_SOURCE) {
    return bytes_read;
  }
  else if (result == LZWS_DECOMPRESSOR_INVALID_MAGIC_HEADER) {
    lzws_ext_raise_error("ValidateError", "validate error");
  }
  else {
    lzws_ext_raise_error("UnexpectedError", "unexpected error");
  }
}

VALUE lzws_ext_decompress(VALUE self, VALUE source)
{
  GET_DECOMPRESSOR();
  DO_NOT_USE_AFTER_CLOSE();
  GET_SOURCE_STRING();

  uint8_t* remaining_source_data   = (uint8_t*)source_data;
  size_t   remaining_source_length = source_length;

  lzws_result_t result = lzws_decompress(
    decompressor_ptr->state_ptr,
    &remaining_source_data,
    &remaining_source_length,
    &decompressor_ptr->remaining_destination_buffer,
    &decompressor_ptr->remaining_destination_buffer_length);

  VALUE bytes_read = INT2NUM(source_length - remaining_source_length);

  VALUE needs_more_destination;
  if (result == LZWS_DECOMPRESSOR_NEEDS_MORE_SOURCE) {
    needs_more_destination = Qfalse;
  }
  else if (result == LZWS_DECOMPRESSOR_NEEDS_MORE_DESTINATION) {
    needs_more_destination = Qtrue;
  }
  else if (result == LZWS_DECOMPRESSOR_INVALID_MAX_CODE_BIT_LENGTH) {
    lzws_ext_raise_error("ValidateError", "validate error");
  }
  else if (result == LZWS_DECOMPRESSOR_CORRUPTED_SOURCE) {
    lzws_ext_raise_error("DecompressorCorruptedSourceError", "decompressor received corrupted source");
  }
  else {
    lzws_ext_raise_error("UnexpectedError", "unexpected error");
  }

  return rb_ary_new_from_args(2, bytes_read, needs_more_destination);
}

VALUE lzws_ext_decompressor_read_result(VALUE self)
{
  GET_DECOMPRESSOR();
  DO_NOT_USE_AFTER_CLOSE();

  uint8_t* destination_buffer                  = decompressor_ptr->destination_buffer;
  size_t   destination_buffer_length           = decompressor_ptr->destination_buffer_length;
  size_t   remaining_destination_buffer_length = decompressor_ptr->remaining_destination_buffer_length;

  const char* result_data   = (const char*)destination_buffer;
  size_t      result_length = destination_buffer_length - remaining_destination_buffer_length;

  VALUE result = rb_str_new(result_data, result_length);

  decompressor_ptr->remaining_destination_buffer        = destination_buffer;
  decompressor_ptr->remaining_destination_buffer_length = destination_buffer_length;

  return result;
}

VALUE lzws_ext_decompressor_close(VALUE self)
{
  GET_DECOMPRESSOR();
  DO_NOT_USE_AFTER_CLOSE();

  lzws_decompressor_state_t* state_ptr = decompressor_ptr->state_ptr;
  if (state_ptr != NULL) {
    lzws_decompressor_free_state(state_ptr);

    decompressor_ptr->state_ptr = NULL;
  }

  uint8_t* destination_buffer = decompressor_ptr->destination_buffer;
  if (destination_buffer != NULL) {
    free(destination_buffer);

    decompressor_ptr->destination_buffer = NULL;
  }

  // It is possible to keep "destination_buffer_length", "remaining_destination_buffer"
  //   and "remaining_destination_buffer_length" as is.

  return Qnil;
}

void lzws_ext_decompressor_exports(VALUE root_module)
{
  VALUE stream = rb_define_module_under(root_module, "Stream");

  VALUE decompressor = rb_define_class_under(stream, "NativeDecompressor", rb_cObject);
  rb_define_alloc_func(decompressor, lzws_ext_allocate_decompressor);
  rb_define_method(decompressor, "initialize", lzws_ext_initialize_decompressor, 1);
  rb_define_method(decompressor, "read_magic_header", lzws_ext_decompressor_read_magic_header, 1);
  rb_define_method(decompressor, "read", lzws_ext_decompress, 1);
  rb_define_method(decompressor, "read_result", lzws_ext_decompressor_read_result, 0);
  rb_define_method(decompressor, "close", lzws_ext_decompressor_close, 0);
}
