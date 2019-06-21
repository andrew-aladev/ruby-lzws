// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include <lzws/buffer.h>
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

VALUE lzws_ext_initialize_compressor(VALUE LZWS_EXT_UNUSED(self), VALUE options)
{
  LZWS_EXT_GET_COMPRESSOR_OPTIONS(options);

  lzws_ext_compressor_t* compressor_ptr;
  Data_Get_Struct(self, lzws_ext_compressor_t, compressor_ptr);

  // -----

  lzws_compressor_state_t* compressor_state_ptr;

  lzws_result_t result = lzws_compressor_get_initial_state(
    &compressor_state_ptr,
    max_code_bit_length, block_mode, msb, unaligned_bit_groups, quiet);

  if (result != 0) {
    lzws_ext_raise_error("CompressorError", "compressor error");
  }

  compressor_ptr->state_ptr = compressor_state_ptr;

  // -----

  uint8_t* destination_buffer;
  size_t   destination_buffer_length = 0;

  result = lzws_create_buffer_for_compressor(&destination_buffer, &destination_buffer_length, quiet);
  if (result != 0) {
    lzws_ext_raise_error("MemoryAllocationError", "memory allocation error");
  }

  compressor_ptr->destination_buffer                  = destination_buffer;
  compressor_ptr->destination_buffer_length           = destination_buffer_length;
  compressor_ptr->remaining_destination_buffer        = destination_buffer;
  compressor_ptr->remaining_destination_buffer_length = destination_buffer_length;

  return Qnil;
}
