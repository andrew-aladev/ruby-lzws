// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include <lzws/file.h>

#include "lzws_ext/error.h"
#include "lzws_ext/io.h"
#include "lzws_ext/macro.h"
#include "lzws_ext/option.h"
#include "ruby.h"
#include "ruby/io.h"

#define GET_FILE(target)                                          \
  Check_Type(target, T_FILE);                                     \
                                                                  \
  rb_io_t *target##_io;                                           \
  GetOpenFile(target, target##_io);                               \
                                                                  \
  FILE *target##_file = rb_io_stdio_file(target##_io);            \
  if (target##_file == NULL) {                                    \
    lzws_ext_raise_error("AccessIOError", "failed to access IO"); \
  }

VALUE lzws_ext_compress_io(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE destination, VALUE options)
{
  GET_FILE(source);
  GET_FILE(destination);
  LZWS_EXT_GET_COMPRESSOR_OPTIONS(options);

  lzws_result_t result = lzws_compress_file(
    source_file, buffer_length,
    destination_file, buffer_length,
    without_magic_header, max_code_bit_length, block_mode, msb, unaligned_bit_groups, quiet);

  if (result == LZWS_FILE_ALLOCATE_FAILED) {
    lzws_ext_raise_error("AllocateError", "allocate error");
  }
  else if (result == LZWS_FILE_VALIDATE_FAILED) {
    lzws_ext_raise_error("ValidateError", "validate error");
  }
  else if (result == LZWS_FILE_READ_FAILED) {
    lzws_ext_raise_error("ReadIOError", "failed to read IO");
  }
  else if (result == LZWS_FILE_WRITE_FAILED) {
    lzws_ext_raise_error("WriteIOError", "failed to write IO");
  }
  else if (result != 0) {
    lzws_ext_raise_error("UnexpectedError", "unexpected error");
  }

  // Ruby itself won't flush stdio file before closing fd, flush is required.
  fflush(destination_file);

  return Qnil;
}

VALUE lzws_ext_decompress_io(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE destination, VALUE options)
{
  GET_FILE(source);
  GET_FILE(destination);
  LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options);

  lzws_result_t result = lzws_decompress_file(
    source_file, buffer_length,
    destination_file, buffer_length,
    without_magic_header, msb, unaligned_bit_groups, quiet);

  if (result == LZWS_FILE_ALLOCATE_FAILED) {
    lzws_ext_raise_error("AllocateError", "allocate error");
  }
  else if (result == LZWS_FILE_VALIDATE_FAILED) {
    lzws_ext_raise_error("ValidateError", "validate error");
  }
  else if (result == LZWS_FILE_DECOMPRESSOR_CORRUPTED_SOURCE) {
    lzws_ext_raise_error("DecompressorCorruptedSourceError", "decompressor received corrupted source");
  }
  else if (result == LZWS_FILE_READ_FAILED) {
    lzws_ext_raise_error("ReadIOError", "failed to read IO");
  }
  else if (result == LZWS_FILE_WRITE_FAILED) {
    lzws_ext_raise_error("WriteIOError", "failed to write IO");
  }
  else if (result != 0) {
    lzws_ext_raise_error("UnexpectedError", "unexpected error");
  }

  // Ruby itself won't flush stdio file before closing fd, flush is required.
  fflush(destination_file);

  return Qnil;
}
