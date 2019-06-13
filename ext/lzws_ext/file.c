// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include <lzws/file.h>

#include "lzws_ext/error.h"
#include "lzws_ext/file.h"
#include "lzws_ext/macro.h"
#include "lzws_ext/option.h"
#include "ruby.h"
#include "ruby/io.h"

VALUE lzws_ext_compress_file(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE destination, VALUE options)
{
  Check_Type(source, T_FILE);
  Check_Type(destination, T_FILE);

  rb_io_t *source_io, *destination_io;
  GetOpenFile(source, source_io);
  GetOpenFile(destination, destination_io);

  LZWS_EXT_GET_COMPRESSOR_OPTIONS(options);

  // -----

  FILE *source_file = rb_io_stdio_file(source_io);
  if (source_file == NULL) {
    lzws_ext_raise_error("OpenFileFailedError", "failed to open source file");
    return Qnil;
  }

  FILE *destination_file = rb_io_stdio_file(destination_io);
  if (destination_file == NULL) {
    lzws_ext_raise_error("OpenFileFailedError", "failed to open destination file");
    return Qnil;
  }

  lzws_result_t result = lzws_compress_file(
    source_file, 0,
    destination_file, 0,
    max_code_bit_length, block_mode, msb, unaligned_bit_groups, quiet);

  // Ruby itself won't flush destination file, flush is required.
  fflush(destination_file);

  // -----

  if (result == LZWS_FILE_COMPRESSOR_FAILED) {
    lzws_ext_raise_error("CompressorFailedError", "compressor failed");
  }
  else if (result == LZWS_FILE_READ_FAILED) {
    lzws_ext_raise_error("ReadFileFailedError", "failed to read file");
  }
  else if (result == LZWS_FILE_WRITE_FAILED) {
    lzws_ext_raise_error("WriteFileFailedError", "failed to write file");
  }
  else if (result != 0) {
    lzws_ext_raise_error("UnexpectedError", "unexpected error");
  }

  return Qnil;
}

VALUE lzws_ext_decompress_file(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE destination, VALUE options)
{
  Check_Type(source, T_FILE);
  Check_Type(destination, T_FILE);

  rb_io_t *source_io, *destination_io;
  GetOpenFile(source, source_io);
  GetOpenFile(destination, destination_io);

  LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options);

  // -----

  FILE *source_file = rb_io_stdio_file(source_io);
  if (source_file == NULL) {
    lzws_ext_raise_error("OpenFileFailedError", "failed to open source file");
    return Qnil;
  }

  FILE *destination_file = rb_io_stdio_file(destination_io);
  if (destination_file == NULL) {
    lzws_ext_raise_error("OpenFileFailedError", "failed to open destination file");
    return Qnil;
  }

  lzws_result_t result = lzws_decompress_file(
    source_file, 0,
    destination_file, 0,
    msb, unaligned_bit_groups, quiet);

  // Ruby itself won't flush destination file, flush is required.
  fflush(destination_file);

  // -----

  if (result == LZWS_FILE_DECOMPRESSOR_FAILED) {
    lzws_ext_raise_error("DecompressorFailedError", "decompressor failed");
  }
  else if (result == LZWS_FILE_READ_FAILED) {
    lzws_ext_raise_error("ReadFileFailedError", "failed to read file");
  }
  else if (result == LZWS_FILE_WRITE_FAILED) {
    lzws_ext_raise_error("WriteFileFailedError", "failed to write file");
  }
  else if (result != 0) {
    lzws_ext_raise_error("UnexpectedError", "unexpected error");
  }

  return Qnil;
}
