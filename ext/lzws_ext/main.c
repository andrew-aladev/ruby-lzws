// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/buffer.h"
#include "lzws_ext/common.h"
#include "lzws_ext/io.h"
#include "lzws_ext/stream/compressor.h"
#include "lzws_ext/stream/decompressor.h"
#include "lzws_ext/string.h"
#include "ruby.h"

void Init_lzws_ext()
{
  VALUE root_module = rb_define_module(LZWS_EXT_MODULE_NAME);

  lzws_ext_buffer_exports(root_module);
  lzws_ext_io_exports(root_module);
  lzws_ext_compressor_exports(root_module);
  lzws_ext_decompressor_exports(root_module);
  lzws_ext_string_exports(root_module);
}
