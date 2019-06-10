// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include <lzws/string.h>

#include "macro.h"
#include "ruby.h"
#include "string.h"

VALUE lzws_ext_compress_string(VALUE LZWS_EXT_UNUSED(self), VALUE source)
{
  Check_Type(source, T_STRING);

  return Qnil;
}

VALUE lzws_ext_decompress_string(VALUE LZWS_EXT_UNUSED(self), VALUE source)
{
  Check_Type(source, T_STRING);

  return Qnil;
}
