// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/file.h"
#include "lzws_ext/string.h"
#include "ruby.h"

void Init_lzws_ext()
{
  VALUE module = rb_define_module("LZWS");

  rb_define_module_function(module, "_compress_file", RUBY_METHOD_FUNC(lzws_ext_compress_file), 3);
  rb_define_module_function(module, "_decompress_file", RUBY_METHOD_FUNC(lzws_ext_decompress_file), 3);
  rb_define_module_function(module, "_compress_string", RUBY_METHOD_FUNC(lzws_ext_compress_string), 2);
  rb_define_module_function(module, "_decompress_string", RUBY_METHOD_FUNC(lzws_ext_decompress_string), 2);
}
