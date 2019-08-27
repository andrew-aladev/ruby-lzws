// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_OPTIONS_H)
#define LZWS_EXT_OPTIONS_H

#include "ruby.h"

#include "lzws_ext/error.h"

#define LZWS_EXT_GET_OPTION(name) \
  VALUE name##_value = rb_funcall(options, rb_intern("[]"), 1, ID2SYM(rb_intern(#name)));

#define LZWS_EXT_GET_BOOL_OPTION(name)                           \
  LZWS_EXT_GET_OPTION(name);                                     \
                                                                 \
  int name##_type = TYPE(name##_value);                          \
  if (name##_type != T_TRUE && name##_type != T_FALSE) {         \
    lzws_ext_raise_error("ValidateError", "invalid bool value"); \
  }                                                              \
                                                                 \
  bool name = name##_type == T_TRUE;

#define LZWS_EXT_GET_FIXNUM_OPTION(type, name) \
  LZWS_EXT_GET_OPTION(name);                   \
                                               \
  Check_Type(name##_value, T_FIXNUM);          \
                                               \
  type name = rb_num2uint(name##_value);

#define LZWS_EXT_GET_COMPRESSOR_OPTIONS(options)                 \
  Check_Type(options, T_HASH);                                   \
                                                                 \
  LZWS_EXT_GET_FIXNUM_OPTION(size_t, buffer_length);             \
  LZWS_EXT_GET_BOOL_OPTION(without_magic_header);                \
  LZWS_EXT_GET_FIXNUM_OPTION(uint_fast8_t, max_code_bit_length); \
  LZWS_EXT_GET_BOOL_OPTION(block_mode);                          \
  LZWS_EXT_GET_BOOL_OPTION(msb);                                 \
  LZWS_EXT_GET_BOOL_OPTION(unaligned_bit_groups);                \
  LZWS_EXT_GET_BOOL_OPTION(quiet);

#define LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options)   \
  Check_Type(options, T_HASH);                       \
                                                     \
  LZWS_EXT_GET_FIXNUM_OPTION(size_t, buffer_length); \
  LZWS_EXT_GET_BOOL_OPTION(without_magic_header);    \
  LZWS_EXT_GET_BOOL_OPTION(msb);                     \
  LZWS_EXT_GET_BOOL_OPTION(unaligned_bit_groups);    \
  LZWS_EXT_GET_BOOL_OPTION(quiet);

#endif // LZWS_EXT_OPTIONS_H
