// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include <lzws/file.h>

#include "lzws_ext/common.h"
#include "lzws_ext/file.h"
#include "lzws_ext/macro.h"
#include "ruby.h"

VALUE lzws_ext_compress_file(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE destination, VALUE options)
{
  Check_Type(source, T_STRING);
  Check_Type(destination, T_STRING);

  LZWS_EXT_GET_COMPRESSOR_OPTIONS(options);

  // lzws_result_t result = lzws_compress_file(
  // source_file, 0,
  // destination_file, 0,
  // max_code_bit_length, block_mode, msb, unaligned_bit_groups, quiet);

  return Qnil;
}

VALUE lzws_ext_decompress_file(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE destination, VALUE options)
{
  Check_Type(source, T_STRING);
  Check_Type(destination, T_STRING);

  LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options);

  return Qnil;
}
