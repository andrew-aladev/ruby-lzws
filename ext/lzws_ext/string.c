// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/string.h"

#include <lzws/buffer.h>
#include <lzws/common.h>
#include <lzws/compressor/common.h>
#include <lzws/compressor/main.h>
#include <lzws/compressor/state.h>
#include <lzws/decompressor/common.h>
#include <lzws/decompressor/main.h>
#include <lzws/decompressor/state.h>
#include <stdlib.h>

#include "lzws_ext/buffer.h"
#include "lzws_ext/error.h"
#include "lzws_ext/macro.h"
#include "lzws_ext/option.h"
#include "ruby.h"

// -- buffer --

static inline lzws_ext_result_t increase_destination_buffer(
  VALUE destination_value, size_t destination_length,
  size_t* remaining_destination_buffer_length_ptr, size_t destination_buffer_length)
{
  if (*remaining_destination_buffer_length_ptr == destination_buffer_length) {
    // We want to write more data at once, than buffer has.
    return LZWS_EXT_ERROR_NOT_ENOUGH_DESTINATION_BUFFER;
  }

  int exception;

  LZWS_EXT_RESIZE_STRING_BUFFER(destination_value, destination_length + destination_buffer_length, exception);
  if (exception != 0) {
    return LZWS_EXT_ERROR_ALLOCATE_FAILED;
  }

  *remaining_destination_buffer_length_ptr = destination_buffer_length;

  return 0;
}

// -- utils --

#define GET_SOURCE_DATA(source_value)                    \
  Check_Type(source_value, T_STRING);                    \
                                                         \
  const char* source        = RSTRING_PTR(source_value); \
  size_t      source_length = RSTRING_LEN(source_value);

// -- compress --

#define BUFFERED_COMPRESS(function, ...)                                                                                               \
  while (true) {                                                                                                                       \
    lzws_ext_byte_t* remaining_destination_buffer             = (lzws_ext_byte_t*)RSTRING_PTR(destination_value) + destination_length; \
    size_t           prev_remaining_destination_buffer_length = remaining_destination_buffer_length;                                   \
                                                                                                                                       \
    result = function(__VA_ARGS__, &remaining_destination_buffer, &remaining_destination_buffer_length);                               \
                                                                                                                                       \
    if (                                                                                                                               \
      result != 0 &&                                                                                                                   \
      result != LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION) {                                                                              \
      return LZWS_EXT_ERROR_UNEXPECTED;                                                                                                \
    }                                                                                                                                  \
                                                                                                                                       \
    destination_length += prev_remaining_destination_buffer_length - remaining_destination_buffer_length;                              \
                                                                                                                                       \
    if (result == LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION) {                                                                            \
      ext_result = increase_destination_buffer(                                                                                        \
        destination_value, destination_length,                                                                                         \
        &remaining_destination_buffer_length, destination_buffer_length);                                                              \
                                                                                                                                       \
      if (ext_result != 0) {                                                                                                           \
        return ext_result;                                                                                                             \
      }                                                                                                                                \
                                                                                                                                       \
      continue;                                                                                                                        \
    }                                                                                                                                  \
                                                                                                                                       \
    break;                                                                                                                             \
  }

static inline lzws_ext_result_t compress(
  lzws_compressor_state_t* state_ptr,
  const char* source, size_t source_length,
  VALUE destination_value, size_t destination_buffer_length)
{
  lzws_result_t     result;
  lzws_ext_result_t ext_result;

  lzws_ext_byte_t* remaining_source        = (lzws_ext_byte_t*)source;
  size_t           remaining_source_length = source_length;

  size_t destination_length                  = 0;
  size_t remaining_destination_buffer_length = destination_buffer_length;

  BUFFERED_COMPRESS(lzws_compress, state_ptr, &remaining_source, &remaining_source_length);
  BUFFERED_COMPRESS(lzws_compressor_finish, state_ptr);

  int exception;

  LZWS_EXT_RESIZE_STRING_BUFFER(destination_value, destination_length, exception);
  if (exception != 0) {
    return LZWS_EXT_ERROR_ALLOCATE_FAILED;
  }

  return 0;
}

VALUE lzws_ext_compress_string(VALUE LZWS_EXT_UNUSED(self), VALUE source_value, VALUE options)
{
  GET_SOURCE_DATA(source_value);
  Check_Type(options, T_HASH);
  LZWS_EXT_GET_COMPRESSOR_OPTIONS(options);
  LZWS_EXT_GET_BUFFER_LENGTH_OPTION(options, destination_buffer_length);

  lzws_compressor_state_t* state_ptr;

  lzws_result_t result = lzws_compressor_get_initial_state(
    &state_ptr,
    without_magic_header, max_code_bit_length, block_mode, msb, unaligned_bit_groups, quiet);

  if (result != 0) {
    switch (result) {
      case LZWS_COMPRESSOR_ALLOCATE_FAILED:
        lzws_ext_raise_error(LZWS_EXT_ERROR_ALLOCATE_FAILED);
      case LZWS_COMPRESSOR_INVALID_MAX_CODE_BIT_LENGTH:
        lzws_ext_raise_error(LZWS_EXT_ERROR_VALIDATE_FAILED);
      default:
        lzws_ext_raise_error(LZWS_EXT_ERROR_UNEXPECTED);
    }
  }

  if (destination_buffer_length == 0) {
    destination_buffer_length = LZWS_DEFAULT_DESTINATION_BUFFER_LENGTH_FOR_COMPRESSOR;
  }

  int exception;

  LZWS_EXT_CREATE_STRING_BUFFER(destination_value, destination_buffer_length, exception);
  if (exception != 0) {
    lzws_compressor_free_state(state_ptr);
    lzws_ext_raise_error(LZWS_EXT_ERROR_ALLOCATE_FAILED);
  }

  lzws_ext_result_t ext_result = compress(
    state_ptr,
    source, source_length,
    destination_value, destination_buffer_length);

  lzws_compressor_free_state(state_ptr);

  if (ext_result != 0) {
    lzws_ext_raise_error(ext_result);
  }

  return destination_value;
}

// -- decompress --

static inline lzws_ext_result_t decompress(
  lzws_decompressor_state_t* state_ptr,
  const char* source, size_t source_length,
  VALUE destination_value, size_t destination_buffer_length)
{
  lzws_result_t     result;
  lzws_ext_result_t ext_result;

  lzws_ext_byte_t* remaining_source        = (lzws_ext_byte_t*)source;
  size_t           remaining_source_length = source_length;

  size_t destination_length                  = 0;
  size_t remaining_destination_buffer_length = destination_buffer_length;

  while (true) {
    lzws_ext_byte_t* remaining_destination_buffer             = (lzws_ext_byte_t*)RSTRING_PTR(destination_value) + destination_length;
    size_t           prev_remaining_destination_buffer_length = remaining_destination_buffer_length;

    result = lzws_decompress(
      state_ptr,
      &remaining_source, &remaining_source_length,
      &remaining_destination_buffer, &remaining_destination_buffer_length);

    if (
      result != 0 &&
      result != LZWS_DECOMPRESSOR_NEEDS_MORE_DESTINATION) {
      switch (result) {
        case LZWS_DECOMPRESSOR_INVALID_MAGIC_HEADER:
        case LZWS_DECOMPRESSOR_INVALID_MAX_CODE_BIT_LENGTH:
          return LZWS_EXT_ERROR_VALIDATE_FAILED;
        case LZWS_DECOMPRESSOR_CORRUPTED_SOURCE:
          return LZWS_EXT_ERROR_DECOMPRESSOR_CORRUPTED_SOURCE;
        default:
          return LZWS_EXT_ERROR_UNEXPECTED;
      }
    }

    destination_length += prev_remaining_destination_buffer_length - remaining_destination_buffer_length;

    if (result == LZWS_DECOMPRESSOR_NEEDS_MORE_DESTINATION) {
      ext_result = increase_destination_buffer(
        destination_value, destination_length,
        &remaining_destination_buffer_length, destination_buffer_length);

      if (ext_result != 0) {
        return ext_result;
      }

      continue;
    }

    break;
  }

  int exception;

  LZWS_EXT_RESIZE_STRING_BUFFER(destination_value, destination_length, exception);
  if (exception != 0) {
    return LZWS_EXT_ERROR_ALLOCATE_FAILED;
  }

  return 0;
}

VALUE lzws_ext_decompress_string(VALUE LZWS_EXT_UNUSED(self), VALUE source_value, VALUE options)
{
  GET_SOURCE_DATA(source_value);
  Check_Type(options, T_HASH);
  LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options);
  LZWS_EXT_GET_BUFFER_LENGTH_OPTION(options, destination_buffer_length);

  lzws_decompressor_state_t* state_ptr;

  lzws_result_t result = lzws_decompressor_get_initial_state(
    &state_ptr,
    without_magic_header, msb, unaligned_bit_groups, quiet);

  if (result != 0) {
    switch (result) {
      case LZWS_DECOMPRESSOR_ALLOCATE_FAILED:
        lzws_ext_raise_error(LZWS_EXT_ERROR_ALLOCATE_FAILED);
      default:
        lzws_ext_raise_error(LZWS_EXT_ERROR_UNEXPECTED);
    }
  }

  if (destination_buffer_length == 0) {
    destination_buffer_length = LZWS_DEFAULT_DESTINATION_BUFFER_LENGTH_FOR_DECOMPRESSOR;
  }

  int exception;

  LZWS_EXT_CREATE_STRING_BUFFER(destination_value, destination_buffer_length, exception);
  if (exception != 0) {
    lzws_decompressor_free_state(state_ptr);
    lzws_ext_raise_error(LZWS_EXT_ERROR_ALLOCATE_FAILED);
  }

  lzws_ext_result_t ext_result = decompress(
    state_ptr,
    source, source_length,
    destination_value, destination_buffer_length);

  lzws_decompressor_free_state(state_ptr);

  if (ext_result != 0) {
    lzws_ext_raise_error(ext_result);
  }

  return destination_value;
}

void lzws_ext_string_exports(VALUE root_module)
{
  rb_define_module_function(root_module, "_native_compress_string", RUBY_METHOD_FUNC(lzws_ext_compress_string), 2);
  rb_define_module_function(root_module, "_native_decompress_string", RUBY_METHOD_FUNC(lzws_ext_decompress_string), 2);
}
