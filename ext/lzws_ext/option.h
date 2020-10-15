// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_OPTIONS_H)
#define LZWS_EXT_OPTIONS_H

#include <lzws/compressor/common.h>
#include <lzws/decompressor/common.h>
#include <stdbool.h>
#include <stdlib.h>

#include "ruby.h"

void lzws_ext_resolve_bool_option(VALUE options, bool* option, const char* name);
void lzws_ext_resolve_max_code_bit_length_option(VALUE options, lzws_byte_fast_t* option, const char* name);

#define LZWS_EXT_RESOLVE_BOOL_OPTION(options, target_options, name) \
  lzws_ext_resolve_bool_option(options, &target_options.name, #name);

#define LZWS_EXT_RESOLVE_MAX_CODE_BIT_LENGTH_OPTION(options, target_options, name) \
  lzws_ext_resolve_max_code_bit_length_option(options, &target_options.name, #name);

#define LZWS_EXT_GET_COMPRESSOR_OPTIONS(options)                                                 \
  lzws_compressor_options_t compressor_options = LZWS_COMPRESSOR_DEFAULT_OPTIONS;                \
                                                                                                 \
  LZWS_EXT_RESOLVE_BOOL_OPTION(options, compressor_options, without_magic_header);               \
  LZWS_EXT_RESOLVE_MAX_CODE_BIT_LENGTH_OPTION(options, compressor_options, max_code_bit_length); \
  LZWS_EXT_RESOLVE_BOOL_OPTION(options, compressor_options, block_mode);                         \
  LZWS_EXT_RESOLVE_BOOL_OPTION(options, compressor_options, msb);                                \
  LZWS_EXT_RESOLVE_BOOL_OPTION(options, compressor_options, unaligned_bit_groups);               \
  LZWS_EXT_RESOLVE_BOOL_OPTION(options, compressor_options, quiet);

#define LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options)                                      \
  lzws_decompressor_options_t decompressor_options = LZWS_DECOMPRESSOR_DEFAULT_OPTIONS; \
                                                                                        \
  LZWS_EXT_RESOLVE_BOOL_OPTION(options, decompressor_options, without_magic_header);    \
  LZWS_EXT_RESOLVE_BOOL_OPTION(options, decompressor_options, msb);                     \
  LZWS_EXT_RESOLVE_BOOL_OPTION(options, decompressor_options, unaligned_bit_groups);    \
  LZWS_EXT_RESOLVE_BOOL_OPTION(options, decompressor_options, quiet);

bool   lzws_ext_get_bool_option_value(VALUE options, const char* name);
size_t lzws_ext_get_size_option_value(VALUE options, const char* name);

#define LZWS_EXT_GET_BOOL_OPTION(options, name) bool name = lzws_ext_get_bool_option_value(options, #name);
#define LZWS_EXT_GET_SIZE_OPTION(options, name) size_t name = lzws_ext_get_size_option_value(options, #name);

void lzws_ext_option_exports(VALUE root_module);

#endif // LZWS_EXT_OPTIONS_H
