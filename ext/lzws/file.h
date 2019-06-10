// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_FILE_H)
#define LZWS_EXT_FILE_H

#include "ruby.h"

VALUE lzws_ext_compress_file(VALUE self, VALUE source, VALUE destination);
VALUE lzws_ext_decompress_file(VALUE self, VALUE source, VALUE destination);

#endif // LZWS_EXT_FILE_H
