// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_STREAM_COMPRESSOR_H)
#define LZWS_EXT_STREAM_COMPRESSOR_H

#include <lzws/compressor/state.h>

#include "ruby.h"

typedef struct {
  lzws_compressor_state_t* state_ptr;
  uint8_t*                 destination_buffer;
  size_t                   destination_buffer_length;
  uint8_t*                 remaining_destination_buffer;
  size_t                   remaining_destination_buffer_length;
} lzws_ext_compressor_t;

VALUE lzws_ext_allocate_compressor(VALUE klass);
VALUE lzws_ext_initialize_compressor(VALUE self, VALUE options);
VALUE lzws_ext_compressor_write_magic_header(VALUE self);
VALUE lzws_ext_compress(VALUE self, VALUE source);
VALUE lzws_ext_finish_compressor(VALUE self);
VALUE lzws_ext_compressor_read_result(VALUE self);
VALUE lzws_ext_compressor_close(VALUE self);

#endif // LZWS_EXT_STREAM_COMPRESSOR_H
