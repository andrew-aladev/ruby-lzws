// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_COMMON_H)
#define LZWS_EXT_COMMON_H

#include "ruby.h"

VALUE lzws_ext_get_option(VALUE options, const char* name);
void  lzws_ext_check_bool_type(VALUE option, const char* name);

#define LZWS_EXT_GET_COMPRESSOR_OPTIONS(options)                                           \
  Check_Type(options, T_HASH);                                                             \
                                                                                           \
  VALUE max_code_bit_length_value  = lzws_ext_get_option(options, "max_code_bit_length");  \
  VALUE block_mode_value           = lzws_ext_get_option(options, "block_mode");           \
  VALUE msb_value                  = lzws_ext_get_option(options, "msb");                  \
  VALUE unaligned_bit_groups_value = lzws_ext_get_option(options, "unaligned_bit_groups"); \
  VALUE quiet_value                = lzws_ext_get_option(options, "quiet");                \
                                                                                           \
  Check_Type(max_code_bit_length_value, T_FIXNUM);                                         \
  lzws_ext_check_bool_type(block_mode_value, "block_mode");                                \
  lzws_ext_check_bool_type(msb_value, "msb");                                              \
  lzws_ext_check_bool_type(unaligned_bit_groups_value, "unaligned_bit_groups");            \
  lzws_ext_check_bool_type(quiet_value, "quiet");                                          \
                                                                                           \
  uint_fast8_t max_code_bit_length  = NUM2UINT(max_code_bit_length_value);                 \
  bool         block_mode           = TYPE(block_mode_value) == T_TRUE;                    \
  bool         msb                  = TYPE(msb_value) == T_TRUE;                           \
  bool         unaligned_bit_groups = TYPE(unaligned_bit_groups_value) == T_TRUE;          \
  bool         quiet                = TYPE(quiet_value) == T_TRUE;

#define LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options)                                         \
  Check_Type(options, T_HASH);                                                             \
                                                                                           \
  VALUE msb_value                  = lzws_ext_get_option(options, "msb");                  \
  VALUE unaligned_bit_groups_value = lzws_ext_get_option(options, "unaligned_bit_groups"); \
  VALUE quiet_value                = lzws_ext_get_option(options, "quiet");                \
                                                                                           \
  lzws_ext_check_bool_type(msb_value, "msb");                                              \
  lzws_ext_check_bool_type(unaligned_bit_groups_value, "unaligned_bit_groups");            \
  lzws_ext_check_bool_type(quiet_value, "quiet");                                          \
                                                                                           \
  bool msb                  = TYPE(msb_value) == T_TRUE;                                   \
  bool unaligned_bit_groups = TYPE(unaligned_bit_groups_value) == T_TRUE;                  \
  bool quiet                = TYPE(quiet_value) == T_TRUE;

#endif // LZWS_EXT_COMMON_H
