// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include <lzws/buffer.h>
#include <lzws/decompressor/common.h>
#include <lzws/decompressor/header.h>
#include <lzws/decompressor/main.h>
#include <lzws/decompressor/state.h>

#include "lzws_ext/error.h"
#include "lzws_ext/macro.h"
#include "lzws_ext/option.h"
#include "lzws_ext/stream/decompressor.h"
#include "ruby.h"

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

VALUE lzws_ext_initialize_decompressor(VALUE LZWS_EXT_UNUSED(self), VALUE options)
{
  LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options);

  lzws_ext_decompressor_t* decompressor_ptr;
  Data_Get_Struct(self, lzws_ext_decompressor_t, decompressor_ptr);

  // -----

  lzws_decompressor_state_t* decompressor_state_ptr;

  lzws_result_t result = lzws_decompressor_get_initial_state(
    &decompressor_state_ptr,
    msb, unaligned_bit_groups, quiet);

  if (result == LZWS_DECOMPRESSOR_ALLOCATE_FAILED) {
    lzws_ext_raise_error("AllocateError", "allocate error");
  }
  else if (result != 0) {
    lzws_ext_raise_error("UnexpectedError", "unexpected error");
  }

  decompressor_ptr->state_ptr = decompressor_state_ptr;

  // -----

  uint8_t* destination_buffer;
  size_t   destination_buffer_length = 0;

  result = lzws_create_buffer_for_decompressor(&destination_buffer, &destination_buffer_length, quiet);
  if (result != 0) {
    lzws_ext_raise_error("AllocateError", "allocate error");
  }

  decompressor_ptr->destination_buffer                  = destination_buffer;
  decompressor_ptr->destination_buffer_length           = destination_buffer_length;
  decompressor_ptr->remaining_destination_buffer        = destination_buffer;
  decompressor_ptr->remaining_destination_buffer_length = destination_buffer_length;

  return Qnil;
}

VALUE lzws_ext_decompressor_read_magic_header(VALUE self, VALUE source)
{
  lzws_ext_decompressor_t* decompressor_ptr;
  Data_Get_Struct(self, lzws_ext_decompressor_t, decompressor_ptr);

  Check_Type(source, T_STRING);

  const char* source_data   = RSTRING_PTR(source);
  size_t      source_length = RSTRING_LEN(source);

  uint8_t* remaining_source_data   = (uint8_t*)source_data;
  size_t   remaining_source_length = source_length;

  // -----

  return Qnil;
}

// VALUE lzws_ext_decompressor_read(VALUE self, VALUE source);
// VALUE lzws_ext_decompressor_write(VALUE self);
