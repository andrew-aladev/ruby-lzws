// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "file.h"
#include "ruby.h"
#include "string.h"

void Init_lzws_ext()
{
  VALUE module = rb_define_module("LZWS");

  rb_define_singleton_method(module, "compress_string", RUBY_METHOD_FUNC(lzws_ext_compress_string), 1);
  rb_define_singleton_method(module, "decompress_string", RUBY_METHOD_FUNC(lzws_ext_decompress_string), 1);
  rb_define_singleton_method(module, "compress_file", RUBY_METHOD_FUNC(lzws_ext_compress_file), 2);
  rb_define_singleton_method(module, "decompress_file", RUBY_METHOD_FUNC(lzws_ext_decompress_file), 2);
}
