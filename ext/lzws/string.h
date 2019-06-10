// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_STRING_H)
#define LZWS_EXT_STRING_H

#include "ruby.h"

VALUE lzws_ext_compress_string(VALUE self, VALUE source);
VALUE lzws_ext_decompress_string(VALUE self, VALUE source);

#endif // LZWS_EXT_STRING_H
