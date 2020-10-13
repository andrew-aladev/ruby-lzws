// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/io.h"

#include <lzws/file.h>

#include "lzws_ext/error.h"
#include "lzws_ext/macro.h"
#include "lzws_ext/option.h"
#include "ruby.h"
#include "ruby/io.h"

#define GET_FILE(target)                               \
  Check_Type(target, T_FILE);                          \
                                                       \
  rb_io_t* target##_io;                                \
  GetOpenFile(target, target##_io);                    \
                                                       \
  FILE* target##_file = rb_io_stdio_file(target##_io); \
  if (target##_file == NULL) {                         \
    lzws_ext_raise_error(LZWS_EXT_ERROR_ACCESS_IO);    \
  }

static inline lzws_ext_result_t get_file_error(lzws_result_t result)
{
  switch (result) {
    case LZWS_FILE_ALLOCATE_FAILED:
      return LZWS_EXT_ERROR_ALLOCATE_FAILED;
    case LZWS_FILE_VALIDATE_FAILED:
      return LZWS_EXT_ERROR_VALIDATE_FAILED;

    case LZWS_FILE_NOT_ENOUGH_SOURCE_BUFFER:
      return LZWS_EXT_ERROR_NOT_ENOUGH_SOURCE_BUFFER;
    case LZWS_FILE_NOT_ENOUGH_DESTINATION_BUFFER:
      return LZWS_EXT_ERROR_NOT_ENOUGH_DESTINATION_BUFFER;
    case LZWS_FILE_DECOMPRESSOR_CORRUPTED_SOURCE:
      return LZWS_EXT_ERROR_DECOMPRESSOR_CORRUPTED_SOURCE;

    case LZWS_FILE_READ_FAILED:
      return LZWS_EXT_ERROR_READ_IO;
    case LZWS_FILE_WRITE_FAILED:
      return LZWS_EXT_ERROR_WRITE_IO;

    default:
      return LZWS_EXT_ERROR_UNEXPECTED;
  }
}

VALUE lzws_ext_compress_io(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE destination, VALUE options)
{
  GET_FILE(source);
  GET_FILE(destination);
  Check_Type(options, T_HASH);
  LZWS_EXT_GET_COMPRESSOR_OPTIONS(options);
  LZWS_EXT_GET_BUFFER_LENGTH_OPTION(options, source_buffer_length);
  LZWS_EXT_GET_BUFFER_LENGTH_OPTION(options, destination_buffer_length);

  lzws_result_t result = lzws_compress_file(
    source_file, source_buffer_length, destination_file, destination_buffer_length, &compressor_options);

  if (result != 0) {
    lzws_ext_raise_error(get_file_error(result));
  }

  // Ruby itself won't flush stdio file before closing fd, flush is required.
  fflush(destination_file);

  return Qnil;
}

VALUE lzws_ext_decompress_io(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE destination, VALUE options)
{
  GET_FILE(source);
  GET_FILE(destination);
  Check_Type(options, T_HASH);
  LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options);
  LZWS_EXT_GET_BUFFER_LENGTH_OPTION(options, source_buffer_length);
  LZWS_EXT_GET_BUFFER_LENGTH_OPTION(options, destination_buffer_length);

  lzws_result_t result = lzws_decompress_file(
    source_file, source_buffer_length, destination_file, destination_buffer_length, &decompressor_options);

  if (result != 0) {
    lzws_ext_raise_error(get_file_error(result));
  }

  // Ruby itself won't flush stdio file before closing fd, flush is required.
  fflush(destination_file);

  return Qnil;
}

void lzws_ext_io_exports(VALUE root_module)
{
  rb_define_module_function(root_module, "_native_compress_io", RUBY_METHOD_FUNC(lzws_ext_compress_io), 3);
  rb_define_module_function(root_module, "_native_decompress_io", RUBY_METHOD_FUNC(lzws_ext_decompress_io), 3);
}
