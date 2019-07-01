// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/common.h"
#include "lzws_ext/io.h"
#include "lzws_ext/stream/compressor.h"
#include "lzws_ext/stream/decompressor.h"
#include "lzws_ext/string.h"
#include "ruby.h"

void Init_lzws_ext()
{
  VALUE root = rb_define_module(LZWS_EXT_MODULE_NAME);

  // It is better to use these functions internally and prepare pretty wrappers for public usage.
  rb_define_module_function(root, "_native_compress_io", RUBY_METHOD_FUNC(lzws_ext_compress_io), 3);
  rb_define_module_function(root, "_native_decompress_io", RUBY_METHOD_FUNC(lzws_ext_decompress_io), 3);
  rb_define_module_function(root, "_native_compress_string", RUBY_METHOD_FUNC(lzws_ext_compress_string), 2);
  rb_define_module_function(root, "_native_decompress_string", RUBY_METHOD_FUNC(lzws_ext_decompress_string), 2);

  // -----

  VALUE stream = rb_define_module_under(root, "Stream");

  VALUE compressor = rb_define_class_under(stream, "NativeCompressor", rb_cObject);
  rb_define_alloc_func(compressor, lzws_ext_allocate_compressor);
  rb_define_method(compressor, "initialize", lzws_ext_initialize_compressor, 1);
  rb_define_method(compressor, "write_magic_header", lzws_ext_compressor_write_magic_header, 0);
  rb_define_method(compressor, "write", lzws_ext_compress, 1);
  rb_define_method(compressor, "flush", lzws_ext_flush_compressor, 0);
  rb_define_method(compressor, "read_result", lzws_ext_compressor_read_result, 0);

  VALUE decompressor = rb_define_class_under(stream, "NativeDecompressor", rb_cObject);
  rb_define_alloc_func(decompressor, lzws_ext_allocate_decompressor);
  rb_define_method(decompressor, "initialize", lzws_ext_initialize_decompressor, 1);
  rb_define_method(decompressor, "read_magic_header", lzws_ext_decompressor_read_magic_header, 1);
  rb_define_method(decompressor, "read", lzws_ext_decompress, 1);
  rb_define_method(decompressor, "read_result", lzws_ext_decompressor_read_result, 0);
}
