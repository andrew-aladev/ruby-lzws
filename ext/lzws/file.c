// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include <lzws/file.h>

#include "file.h"
#include "macro.h"
#include "ruby.h"

VALUE lzws_ext_compress_file(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE destination)
{
  Check_Type(source, T_FILE);
  Check_Type(destination, T_FILE);

  return Qnil;
}

VALUE lzws_ext_decompress_file(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE destination)
{
  Check_Type(source, T_FILE);
  Check_Type(destination, T_FILE);

  return Qnil;
}
