// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_OPTIONS_H)
#define LZWS_EXT_OPTIONS_H

#include <lzws/compressor/common.h>
#include <lzws/decompressor/common.h>
#include <stdbool.h>
#include <stdlib.h>

#include "lzws_ext/common.h"
#include "ruby.h"

bool         lzws_ext_get_bool_option_value(VALUE options, const char* name);
unsigned int lzws_ext_get_uint_option_value(VALUE options, const char* name);
size_t       lzws_ext_get_size_option_value(VALUE options, const char* name);

#define LZWS_EXT_GET_COMPRESSOR_OPTIONS(options)                                             \
  const lzws_compressor_options_t compressor_options = {                                     \
    .without_magic_header = lzws_ext_get_bool_option_value(options, "without_magic_header"), \
    .max_code_bit_length  = lzws_ext_get_uint_option_value(options, "max_code_bit_length"),  \
    .block_mode           = lzws_ext_get_bool_option_value(options, "block_mode"),           \
    .msb                  = lzws_ext_get_bool_option_value(options, "msb"),                  \
    .unaligned_bit_groups = lzws_ext_get_bool_option_value(options, "unaligned_bit_groups"), \
    .quiet                = lzws_ext_get_bool_option_value(options, "quiet")};

#define LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options)                                           \
  const lzws_decompressor_options_t decompressor_options = {                                 \
    .without_magic_header = lzws_ext_get_bool_option_value(options, "without_magic_header"), \
    .msb                  = lzws_ext_get_bool_option_value(options, "msb"),                  \
    .unaligned_bit_groups = lzws_ext_get_bool_option_value(options, "unaligned_bit_groups"), \
    .quiet                = lzws_ext_get_bool_option_value(options, "quiet")};

#define LZWS_EXT_GET_BUFFER_LENGTH_OPTION(options, name) size_t name = lzws_ext_get_size_option_value(options, #name);

#endif // LZWS_EXT_OPTIONS_H
