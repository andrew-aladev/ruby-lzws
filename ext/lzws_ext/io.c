// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/io.h"

#include <lzws/file.h>

#include "lzws_ext/error.h"
#include "lzws_ext/gvl.h"
#include "lzws_ext/macro.h"
#include "lzws_ext/option.h"
#include "ruby/io.h"

// -- utils --

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

// -- compress --

typedef struct
{
  FILE*                      source_file;
  size_t                     source_buffer_length;
  FILE*                      destination_file;
  size_t                     destination_buffer_length;
  lzws_compressor_options_t* compressor_options_ptr;
  lzws_result_t              result;
} compress_args_t;

static inline void* compress_wrapper(void* data)
{
  compress_args_t* args = data;

  args->result = lzws_compress_file(
    args->source_file,
    args->source_buffer_length,
    args->destination_file,
    args->destination_buffer_length,
    args->compressor_options_ptr);

  return NULL;
}

VALUE lzws_ext_compress_io(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE destination, VALUE options)
{
  GET_FILE(source);
  GET_FILE(destination);
  Check_Type(options, T_HASH);
  LZWS_EXT_GET_SIZE_OPTION(options, source_buffer_length);
  LZWS_EXT_GET_SIZE_OPTION(options, destination_buffer_length);
  LZWS_EXT_GET_BOOL_OPTION(options, gvl);
  LZWS_EXT_GET_COMPRESSOR_OPTIONS(options);

  compress_args_t args = {
    .source_file               = source_file,
    .source_buffer_length      = source_buffer_length,
    .destination_file          = destination_file,
    .destination_buffer_length = destination_buffer_length,
    .compressor_options_ptr    = &compressor_options};

  LZWS_EXT_GVL_WRAP(gvl, compress_wrapper, &args);
  if (args.result != 0) {
    lzws_ext_raise_error(get_file_error(args.result));
  }

  // Ruby itself won't flush stdio file before closing fd, flush is required.
  fflush(destination_file);

  return Qnil;
}

// -- decompress --

typedef struct
{
  FILE*                        source_file;
  size_t                       source_buffer_length;
  FILE*                        destination_file;
  size_t                       destination_buffer_length;
  lzws_decompressor_options_t* decompressor_options_ptr;
  lzws_result_t                result;
} decompress_args_t;

static inline void* decompress_wrapper(void* data)
{
  decompress_args_t* args = data;

  args->result = lzws_decompress_file(
    args->source_file,
    args->source_buffer_length,
    args->destination_file,
    args->destination_buffer_length,
    args->decompressor_options_ptr);

  return NULL;
}

VALUE lzws_ext_decompress_io(VALUE LZWS_EXT_UNUSED(self), VALUE source, VALUE destination, VALUE options)
{
  GET_FILE(source);
  GET_FILE(destination);
  Check_Type(options, T_HASH);
  LZWS_EXT_GET_SIZE_OPTION(options, source_buffer_length);
  LZWS_EXT_GET_SIZE_OPTION(options, destination_buffer_length);
  LZWS_EXT_GET_BOOL_OPTION(options, gvl);
  LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options);

  decompress_args_t args = {
    .source_file               = source_file,
    .source_buffer_length      = source_buffer_length,
    .destination_file          = destination_file,
    .destination_buffer_length = destination_buffer_length,
    .decompressor_options_ptr  = &decompressor_options};

  LZWS_EXT_GVL_WRAP(gvl, decompress_wrapper, &args);
  if (args.result != 0) {
    lzws_ext_raise_error(get_file_error(args.result));
  }

  // Ruby itself won't flush stdio file before closing fd, flush is required.
  fflush(destination_file);

  return Qnil;
}

// -- exports --

void lzws_ext_io_exports(VALUE root_module)
{
  rb_define_module_function(root_module, "_native_compress_io", RUBY_METHOD_FUNC(lzws_ext_compress_io), 3);
  rb_define_module_function(root_module, "_native_decompress_io", RUBY_METHOD_FUNC(lzws_ext_decompress_io), 3);
}
