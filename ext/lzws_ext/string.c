// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/string.h"

#include <lzws/buffer.h>
#include <lzws/compressor/main.h>
#include <lzws/compressor/state.h>
#include <lzws/decompressor/main.h>
#include <lzws/decompressor/state.h>
#include <stdlib.h>

#include "lzws_ext/buffer.h"
#include "lzws_ext/error.h"
#include "lzws_ext/gvl.h"
#include "lzws_ext/macro.h"
#include "lzws_ext/option.h"

// -- buffer --

static inline lzws_ext_result_t increase_destination_buffer(
  VALUE   destination_value,
  size_t  destination_length,
  size_t* remaining_destination_buffer_length_ptr,
  size_t  destination_buffer_length)
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

// -- compress --

typedef struct
{
  lzws_compressor_state_t* state_ptr;
  lzws_ext_byte_t**        remaining_source_ptr;
  size_t*                  remaining_source_length_ptr;
  lzws_ext_byte_t*         remaining_destination_buffer;
  size_t*                  remaining_destination_buffer_length_ptr;
  lzws_result_t            result;
} compress_args_t;

typedef struct
{
  lzws_compressor_state_t* state_ptr;
  lzws_ext_byte_t*         remaining_destination_buffer;
  size_t*                  remaining_destination_buffer_length_ptr;
  lzws_result_t            result;
} compressor_finish_args_t;

static inline void* compress_wrapper(void* data)
{
  compress_args_t* args = data;

  args->result = lzws_compress(
    args->state_ptr,
    args->remaining_source_ptr,
    args->remaining_source_length_ptr,
    &args->remaining_destination_buffer,
    args->remaining_destination_buffer_length_ptr);

  return NULL;
}

static inline void* compressor_finish_wrapper(void* data)
{
  compressor_finish_args_t* args = data;

  args->result = lzws_compressor_finish(
    args->state_ptr, &args->remaining_destination_buffer, args->remaining_destination_buffer_length_ptr);

  return NULL;
}

#define BUFFERED_COMPRESS(gvl, wrapper, args)                                                                    \
  while (true) {                                                                                                 \
    lzws_ext_byte_t* remaining_destination_buffer =                                                              \
      (lzws_ext_byte_t*) RSTRING_PTR(destination_value) + destination_length;                                    \
    size_t prev_remaining_destination_buffer_length = remaining_destination_buffer_length;                       \
                                                                                                                 \
    args.remaining_destination_buffer            = remaining_destination_buffer;                                 \
    args.remaining_destination_buffer_length_ptr = &remaining_destination_buffer_length;                         \
                                                                                                                 \
    LZWS_EXT_GVL_WRAP(gvl, wrapper, &args);                                                                      \
    if (args.result != 0 && args.result != LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION) {                             \
      return LZWS_EXT_ERROR_UNEXPECTED;                                                                          \
    }                                                                                                            \
                                                                                                                 \
    destination_length += prev_remaining_destination_buffer_length - remaining_destination_buffer_length;        \
                                                                                                                 \
    if (args.result == LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION) {                                                 \
      ext_result = increase_destination_buffer(                                                                  \
        destination_value, destination_length, &remaining_destination_buffer_length, destination_buffer_length); \
                                                                                                                 \
      if (ext_result != 0) {                                                                                     \
        return ext_result;                                                                                       \
      }                                                                                                          \
                                                                                                                 \
      continue;                                                                                                  \
    }                                                                                                            \
                                                                                                                 \
    break;                                                                                                       \
  }

static inline lzws_ext_result_t compress(
  lzws_compressor_state_t* state_ptr,
  const char*              source,
  size_t                   source_length,
  VALUE                    destination_value,
  size_t                   destination_buffer_length,
  bool                     gvl)
{
  lzws_ext_result_t ext_result;
  lzws_ext_byte_t*  remaining_source                    = (lzws_ext_byte_t*) source;
  size_t            remaining_source_length             = source_length;
  size_t            destination_length                  = 0;
  size_t            remaining_destination_buffer_length = destination_buffer_length;

  compress_args_t args = {
    .state_ptr                   = state_ptr,
    .remaining_source_ptr        = &remaining_source,
    .remaining_source_length_ptr = &remaining_source_length};

  BUFFERED_COMPRESS(gvl, compress_wrapper, args);

  compressor_finish_args_t finish_args = {.state_ptr = state_ptr};
  BUFFERED_COMPRESS(gvl, compressor_finish_wrapper, finish_args);

  int exception;

  LZWS_EXT_RESIZE_STRING_BUFFER(destination_value, destination_length, exception);
  if (exception != 0) {
    return LZWS_EXT_ERROR_ALLOCATE_FAILED;
  }

  return 0;
}

VALUE lzws_ext_compress_string(VALUE LZWS_EXT_UNUSED(self), VALUE source_value, VALUE options)
{
  Check_Type(source_value, T_STRING);
  Check_Type(options, T_HASH);
  LZWS_EXT_GET_SIZE_OPTION(options, destination_buffer_length);
  LZWS_EXT_GET_BOOL_OPTION(options, gvl);
  LZWS_EXT_GET_COMPRESSOR_OPTIONS(options);

  lzws_compressor_state_t* state_ptr;

  lzws_result_t result = lzws_compressor_get_initial_state(&state_ptr, &compressor_options);
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

  const char* source        = RSTRING_PTR(source_value);
  size_t      source_length = RSTRING_LEN(source_value);

  lzws_ext_result_t ext_result =
    compress(state_ptr, source, source_length, destination_value, destination_buffer_length, gvl);

  lzws_compressor_free_state(state_ptr);

  if (ext_result != 0) {
    lzws_ext_raise_error(ext_result);
  }

  return destination_value;
}

// -- decompress --

typedef struct
{
  lzws_decompressor_state_t* state_ptr;
  lzws_ext_byte_t**          remaining_source_ptr;
  size_t*                    remaining_source_length_ptr;
  lzws_ext_byte_t*           remaining_destination_buffer;
  size_t*                    remaining_destination_buffer_length_ptr;
  lzws_result_t              result;
} decompress_args_t;

static inline void* decompress_wrapper(void* data)
{
  decompress_args_t* args = data;

  args->result = lzws_decompress(
    args->state_ptr,
    args->remaining_source_ptr,
    args->remaining_source_length_ptr,
    &args->remaining_destination_buffer,
    args->remaining_destination_buffer_length_ptr);

  return NULL;
}

static inline lzws_ext_result_t decompress(
  lzws_decompressor_state_t* state_ptr,
  const char*                source,
  size_t                     source_length,
  VALUE                      destination_value,
  size_t                     destination_buffer_length,
  bool                       gvl)
{
  lzws_ext_result_t ext_result;
  lzws_ext_byte_t*  remaining_source                    = (lzws_ext_byte_t*) source;
  size_t            remaining_source_length             = source_length;
  size_t            destination_length                  = 0;
  size_t            remaining_destination_buffer_length = destination_buffer_length;

  decompress_args_t args = {
    .state_ptr                   = state_ptr,
    .remaining_source_ptr        = &remaining_source,
    .remaining_source_length_ptr = &remaining_source_length};

  while (true) {
    lzws_ext_byte_t* remaining_destination_buffer =
      (lzws_ext_byte_t*) RSTRING_PTR(destination_value) + destination_length;
    size_t prev_remaining_destination_buffer_length = remaining_destination_buffer_length;

    args.remaining_destination_buffer            = remaining_destination_buffer;
    args.remaining_destination_buffer_length_ptr = &remaining_destination_buffer_length;

    LZWS_EXT_GVL_WRAP(gvl, decompress_wrapper, &args);
    if (args.result != 0 && args.result != LZWS_DECOMPRESSOR_NEEDS_MORE_DESTINATION) {
      switch (args.result) {
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

    if (args.result == LZWS_DECOMPRESSOR_NEEDS_MORE_DESTINATION) {
      ext_result = increase_destination_buffer(
        destination_value, destination_length, &remaining_destination_buffer_length, destination_buffer_length);

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
  Check_Type(source_value, T_STRING);
  Check_Type(options, T_HASH);
  LZWS_EXT_GET_SIZE_OPTION(options, destination_buffer_length);
  LZWS_EXT_GET_BOOL_OPTION(options, gvl);
  LZWS_EXT_GET_DECOMPRESSOR_OPTIONS(options);

  lzws_decompressor_state_t* state_ptr;

  lzws_result_t result = lzws_decompressor_get_initial_state(&state_ptr, &decompressor_options);
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

  const char* source        = RSTRING_PTR(source_value);
  size_t      source_length = RSTRING_LEN(source_value);

  lzws_ext_result_t ext_result =
    decompress(state_ptr, source, source_length, destination_value, destination_buffer_length, gvl);

  lzws_decompressor_free_state(state_ptr);

  if (ext_result != 0) {
    lzws_ext_raise_error(ext_result);
  }

  return destination_value;
}

// -- exports --

void lzws_ext_string_exports(VALUE root_module)
{
  rb_define_module_function(root_module, "_native_compress_string", RUBY_METHOD_FUNC(lzws_ext_compress_string), 2);
  rb_define_module_function(root_module, "_native_decompress_string", RUBY_METHOD_FUNC(lzws_ext_decompress_string), 2);
}
