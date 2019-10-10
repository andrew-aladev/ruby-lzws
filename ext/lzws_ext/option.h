// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_OPTIONS_H)
#define LZWS_EXT_OPTIONS_H

#include <stdbool.h>

#include "ruby.h"

bool          lzws_ext_get_bool_option(VALUE options, const char* name);
unsigned long lzws_ext_get_fixnum_option(VALUE options, const char* name);

#define LZWS_EXT_GET_BOOL_OPTION(name) \
  bool name = lzws_ext_get_bool_option(options, #name);

#define LZWS_EXT_GET_FIXNUM_OPTION(type, name) \
  type name = lzws_ext_get_fixnum_option(options, #name);

#define LZWS_EXT_GET_COMPRESSOR_OPTIONS(options)                 \
  LZWS_EXT_GET_BOOL_OPTION(without_magic_header);                \
  LZWS_EXT_GET_FIXNUM_OPTION(uint_fast8_t, max_code_bit_length); \
  LZWS_EXT_GET_BOOL_OPTION(block_mode);                          \
  LZWS_EXT_GET_BOOL_OPTION(msb);                                 \
  LZWS_EXT_GET_BOOL_OPTION(unaligned_bit_groups);                \
  LZWS_EXT_GET_BOOL_OPTION(quiet);

#define LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options) \
  LZWS_EXT_GET_BOOL_OPTION(without_magic_header);  \
  LZWS_EXT_GET_BOOL_OPTION(msb);                   \
  LZWS_EXT_GET_BOOL_OPTION(unaligned_bit_groups);  \
  LZWS_EXT_GET_BOOL_OPTION(quiet);

#define LZWS_EXT_GET_BUFFER_LENGTH_OPTION(options, name) \
  LZWS_EXT_GET_FIXNUM_OPTION(size_t, name);

#endif // LZWS_EXT_OPTIONS_H
