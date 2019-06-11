// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include <lzws/file.h>

#include "lzws_ext/common.h"
#include "lzws_ext/file.h"
#include "lzws_ext/macro.h"
#include "ruby.h"

VALUE lzws_ext_compress_file(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE destination, VALUE options)
{
  Check_Type(source, T_FILE);
  Check_Type(destination, T_FILE);

  LZWS_EXT_GET_COMPRESSOR_OPTIONS(options);

  return Qnil;
}

VALUE lzws_ext_decompress_file(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE destination, VALUE options)
{
  Check_Type(source, T_FILE);
  Check_Type(destination, T_FILE);

  LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options);

  return Qnil;
}
