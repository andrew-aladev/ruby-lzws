// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include <lzws/string.h>

#include "lzws_ext/macro.h"
#include "lzws_ext/option.h"
#include "lzws_ext/string.h"
#include "ruby.h"

VALUE lzws_ext_compress_string(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE options)
{
  Check_Type(source, T_STRING);

  LZWS_EXT_GET_COMPRESSOR_OPTIONS(options);

  return Qnil;
}

VALUE lzws_ext_decompress_string(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE options)
{
  Check_Type(source, T_STRING);

  LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options);

  return Qnil;
}
