// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include <lzws/config.h>

#include "lzws_ext/buffer.h"
#include "lzws_ext/io.h"
#include "lzws_ext/option.h"
#include "lzws_ext/stream/compressor.h"
#include "lzws_ext/stream/decompressor.h"
#include "lzws_ext/string.h"

void Init_lzws_ext()
{
  VALUE root_module = rb_define_module(LZWS_EXT_MODULE_NAME);

  lzws_ext_buffer_exports(root_module);
  lzws_ext_io_exports(root_module);
  lzws_ext_option_exports(root_module);
  lzws_ext_compressor_exports(root_module);
  lzws_ext_decompressor_exports(root_module);
  lzws_ext_string_exports(root_module);

  VALUE version = rb_str_new2(LZWS_VERSION);
  rb_define_const(root_module, "LIBRARY_VERSION", rb_obj_freeze(version));
}
