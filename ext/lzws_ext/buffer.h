// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_BUFFER_H)
#define LZWS_EXT_BUFFER_H

#include "ruby.h"

VALUE lzws_ext_create_string_buffer(VALUE length);

#define LZWS_EXT_CREATE_STRING_BUFFER(buffer, length, exception) \
  VALUE buffer = rb_protect(lzws_ext_create_string_buffer, SIZET2NUM(length), &exception);

VALUE lzws_ext_resize_string_buffer(VALUE buffer_args);

#define LZWS_EXT_RESIZE_STRING_BUFFER(buffer, length, exception)                          \
  VALUE buffer_args = rb_ary_new_from_args(2, buffer, SIZET2NUM(length));                 \
  buffer            = rb_protect(lzws_ext_resize_string_buffer, buffer_args, &exception); \
  RB_GC_GUARD(buffer_args);

void lzws_ext_buffer_exports(VALUE root_module);

#endif // LZWS_EXT_BUFFER_H
