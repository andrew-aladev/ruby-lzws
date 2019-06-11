// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_COMMON_H)
#define LZWS_EXT_COMMON_H

#include "ruby.h"

#define LZWS_EXT_GET_OPTION(options, name) rb_funcall( \
  options,                                             \
  rb_intern("[]"),                                     \
  1,                                                   \
  ID2SYM(rb_intern(name)))

#define CHECK_BOOL(option, name)                               \
  do {                                                         \
    int type = TYPE(option);                                   \
                                                               \
    if (type != T_TRUE && type != T_FALSE) {                   \
      rb_exc_raise(                                            \
        rb_exc_new_str(                                        \
          rb_eFatal,                                           \
          rb_sprintf(                                          \
            "wrong value for \"%s\" (expected true or false)", \
            name)));                                           \
    }                                                          \
  } while (0)

#define LZWS_EXT_GET_COMPRESSOR_OPTIONS(options)                                     \
  Check_Type(options, T_HASH);                                                       \
                                                                                     \
  VALUE max_code_bit_length  = LZWS_EXT_GET_OPTION(options, "max_code_bit_length");  \
  VALUE block_mode           = LZWS_EXT_GET_OPTION(options, "block_mode");           \
  VALUE msb                  = LZWS_EXT_GET_OPTION(options, "msb");                  \
  VALUE unaligned_bit_groups = LZWS_EXT_GET_OPTION(options, "unaligned_bit_groups"); \
  VALUE quiet                = LZWS_EXT_GET_OPTION(options, "quiet");                \
                                                                                     \
  Check_Type(max_code_bit_length, T_FIXNUM);                                         \
  CHECK_BOOL(block_mode, "block_mode");                                              \
  CHECK_BOOL(msb, "msb");                                                            \
  CHECK_BOOL(unaligned_bit_groups, "unaligned_bit_groups");                          \
  CHECK_BOOL(quiet, "quiet");

#define LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options)                                   \
  Check_Type(options, T_HASH);                                                       \
                                                                                     \
  VALUE msb                  = LZWS_EXT_GET_OPTION(options, "msb");                  \
  VALUE unaligned_bit_groups = LZWS_EXT_GET_OPTION(options, "unaligned_bit_groups"); \
  VALUE quiet                = LZWS_EXT_GET_OPTION(options, "quiet");                \
                                                                                     \
  CHECK_BOOL(msb, "msb");                                                            \
  CHECK_BOOL(unaligned_bit_groups, "unaligned_bit_groups");                          \
  CHECK_BOOL(quiet, "quiet");

#endif // LZWS_EXT_COMMON_H
