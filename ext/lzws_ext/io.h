// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_IO_H)
#define LZWS_EXT_IO_H

#include "ruby.h"

VALUE lzws_ext_compress_io(VALUE self, VALUE source, VALUE destination, VALUE options);
VALUE lzws_ext_decompress_io(VALUE self, VALUE source, VALUE destination, VALUE options);

void lzws_ext_io_exports(VALUE root_module);

#endif // LZWS_EXT_IO_H
