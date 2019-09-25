// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/string.h"

#include <lzws/buffer.h>
#include <lzws/compressor/common.h>
#include <lzws/compressor/main.h>
#include <lzws/compressor/state.h>
#include <lzws/decompressor/common.h>
#include <lzws/decompressor/main.h>
#include <lzws/decompressor/state.h>

#include "lzws_ext/error.h"
#include "lzws_ext/macro.h"
#include "lzws_ext/option.h"
#include "ruby.h"

#define GET_SOURCE_DATA(source_value)                              \
  Check_Type(source_value, T_STRING);                              \
                                                                   \
  const char* source                  = RSTRING_PTR(source_value); \
  size_t      source_length           = RSTRING_LEN(source_value); \
  uint8_t*    remaining_source        = (uint8_t*)source;          \
  size_t      remaining_source_length = source_length;

// -- buffer --

static inline VALUE create_buffer(VALUE length)
{
  return rb_str_new(NULL, NUM2UINT(length));
}

#define CREATE_BUFFER(buffer, length, exception) \
  VALUE buffer = rb_protect(create_buffer, UINT2NUM(length), &exception);

static inline VALUE resize_buffer(VALUE args)
{
  VALUE buffer = rb_ary_entry(args, 0);
  VALUE length = rb_ary_entry(args, 1);
  return rb_str_resize(buffer, NUM2UINT(length));
}

#define RESIZE_BUFFER(buffer, length, exception)                                        \
  VALUE resize_buffer_args = rb_ary_new_from_args(2, buffer, UINT2NUM(length));         \
  buffer                   = rb_protect(resize_buffer, resize_buffer_args, &exception); \
  RB_GC_GUARD(resize_buffer_args);

static inline lzws_ext_result_t increase_destination_buffer(
  VALUE destination_value, size_t destination_length,
  size_t* remaining_destination_buffer_length_ptr, size_t destination_buffer_length)
{
  if (*remaining_destination_buffer_length_ptr == destination_buffer_length) {
    // We want to write more data at once, than buffer has.
    return LZWS_EXT_ERROR_NOT_ENOUGH_DESTINATION_BUFFER;
  }

  int exception;

  RESIZE_BUFFER(destination_value, destination_length + destination_buffer_length, exception);
  if (exception != 0) {
    return LZWS_EXT_ERROR_ALLOCATE_FAILED;
  }

  *remaining_destination_buffer_length_ptr = destination_buffer_length;

  return 0;
}

// -- compress --

static inline lzws_ext_result_t compress_data(
  lzws_compressor_state_t* state_ptr,
  uint8_t* remaining_source, size_t remaining_source_length,
  VALUE destination_value, size_t destination_buffer_length)
{
  lzws_result_t     result;
  lzws_ext_result_t ext_result;

  size_t destination_length                  = 0;
  size_t remaining_destination_buffer_length = destination_buffer_length;

  bool is_finished = false;

  while (true) {
    uint8_t* remaining_destination_buffer             = (uint8_t*)RSTRING_PTR(destination_value) + destination_length;
    size_t   prev_remaining_destination_buffer_length = remaining_destination_buffer_length;

    if (is_finished) {
      result = lzws_finish_compressor(
        state_ptr,
        &remaining_destination_buffer, &remaining_destination_buffer_length);
    }
    else {
      result = lzws_compress(
        state_ptr,
        &remaining_source, &remaining_source_length,
        &remaining_destination_buffer, &remaining_destination_buffer_length);
    }

    if (
      result != 0 &&
      result != LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION) {
      return LZWS_EXT_ERROR_UNEXPECTED;
    }

    destination_length += prev_remaining_destination_buffer_length - remaining_destination_buffer_length;

    if (result == LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION) {
      ext_result = increase_destination_buffer(
        destination_value, destination_length,
        &remaining_destination_buffer_length, destination_buffer_length);

      if (ext_result != 0) {
        return ext_result;
      }

      continue;
    }

    if (is_finished) {
      break;
    }

    is_finished = true;
  }

  int exception;

  RESIZE_BUFFER(destination_value, destination_length, exception);
  if (exception != 0) {
    return LZWS_EXT_ERROR_ALLOCATE_FAILED;
  }

  return 0;
}

VALUE lzws_ext_compress_string(VALUE LZWS_EXT_UNUSED(self), VALUE source_value, VALUE options)
{
  GET_SOURCE_DATA(source_value);
  LZWS_EXT_GET_COMPRESSOR_OPTIONS(options);

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

  if (buffer_length == 0) {
    buffer_length = LZWS_COMPRESSOR_DEFAULT_BUFFER_LENGTH;
  }

  int exception;

  CREATE_BUFFER(destination_value, buffer_length, exception);
  if (exception != 0) {
    lzws_compressor_free_state(state_ptr);
    lzws_ext_raise_error(LZWS_EXT_ERROR_ALLOCATE_FAILED);
  }

  lzws_ext_result_t ext_result = compress_data(
    state_ptr,
    remaining_source, remaining_source_length,
    destination_value, buffer_length);

  lzws_compressor_free_state(state_ptr);

  if (ext_result != 0) {
    lzws_ext_raise_error(ext_result);
  }

  return destination_value;
}

// -- decompress --

static inline lzws_ext_result_t decompress_data(
  lzws_decompressor_state_t* state_ptr,
  uint8_t* remaining_source, size_t remaining_source_length,
  VALUE destination_value, size_t destination_buffer_length)
{
  lzws_result_t     result;
  lzws_ext_result_t ext_result;

  size_t destination_length                  = 0;
  size_t remaining_destination_buffer_length = destination_buffer_length;

  while (true) {
    uint8_t* remaining_destination_buffer             = (uint8_t*)RSTRING_PTR(destination_value) + destination_length;
    size_t   prev_remaining_destination_buffer_length = remaining_destination_buffer_length;

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

  RESIZE_BUFFER(destination_value, destination_length, exception);
  if (exception != 0) {
    return LZWS_EXT_ERROR_ALLOCATE_FAILED;
  }

  return 0;
}

VALUE lzws_ext_decompress_string(VALUE LZWS_EXT_UNUSED(self), VALUE source_value, VALUE options)
{
  GET_SOURCE_DATA(source_value);
  LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options);

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

  if (buffer_length == 0) {
    buffer_length = LZWS_DECOMPRESSOR_DEFAULT_BUFFER_LENGTH;
  }

  int exception;

  CREATE_BUFFER(destination_value, buffer_length, exception);
  if (exception != 0) {
    lzws_decompressor_free_state(state_ptr);
    lzws_ext_raise_error(LZWS_EXT_ERROR_ALLOCATE_FAILED);
  }

  lzws_ext_result_t ext_result = decompress_data(
    state_ptr,
    remaining_source, remaining_source_length,
    destination_value, buffer_length);

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
