// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_OPTIONS_H)
#define LZWS_EXT_OPTIONS_H

#include <stdbool.h>

#include "ruby.h"

bool          lzws_ext_get_bool_option_value(VALUE options, const char* name);
unsigned long lzws_ext_get_fixnum_option_value(VALUE options, const char* name);

#define LZWS_EXT_GET_BOOL_OPTION(options, name) \
  bool name = lzws_ext_get_bool_option_value(options, #name);

#define LZWS_EXT_GET_FIXNUM_OPTION(options, type, name) \
  type name = lzws_ext_get_fixnum_option_value(options, #name);

#define LZWS_EXT_GET_COMPRESSOR_OPTIONS(options)                          \
  LZWS_EXT_GET_BOOL_OPTION(options, without_magic_header);                \
  LZWS_EXT_GET_FIXNUM_OPTION(options, uint_fast8_t, max_code_bit_length); \
  LZWS_EXT_GET_BOOL_OPTION(options, block_mode);                          \
  LZWS_EXT_GET_BOOL_OPTION(options, msb);                                 \
  LZWS_EXT_GET_BOOL_OPTION(options, unaligned_bit_groups);                \
  LZWS_EXT_GET_BOOL_OPTION(options, quiet);

#define LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options)         \
  LZWS_EXT_GET_BOOL_OPTION(options, without_magic_header); \
  LZWS_EXT_GET_BOOL_OPTION(options, msb);                  \
  LZWS_EXT_GET_BOOL_OPTION(options, unaligned_bit_groups); \
  LZWS_EXT_GET_BOOL_OPTION(options, quiet);

#define LZWS_EXT_GET_BUFFER_LENGTH_OPTION(options, name) \
  LZWS_EXT_GET_FIXNUM_OPTION(options, size_t, name);

#endif // LZWS_EXT_OPTIONS_H
