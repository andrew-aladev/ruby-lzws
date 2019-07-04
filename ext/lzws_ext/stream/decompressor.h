// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_STREAM_DECOMPRESSOR_H)
#define LZWS_EXT_STREAM_DECOMPRESSOR_H

#include <lzws/decompressor/state.h>

#include "ruby.h"

typedef struct {
  lzws_decompressor_state_t* state_ptr;
  uint8_t*                   destination_buffer;
  size_t                     destination_buffer_length;
  uint8_t*                   remaining_destination_buffer;
  size_t                     remaining_destination_buffer_length;
} lzws_ext_decompressor_t;

VALUE lzws_ext_allocate_decompressor(VALUE klass);
VALUE lzws_ext_initialize_decompressor(VALUE self, VALUE options);
VALUE lzws_ext_decompressor_read_magic_header(VALUE self, VALUE source);
VALUE lzws_ext_decompress(VALUE self, VALUE source);
VALUE lzws_ext_decompressor_read_result(VALUE self);
VALUE lzws_ext_decompressor_destroy(VALUE self);

#endif // LZWS_EXT_STREAM_DECOMPRESSOR_H
