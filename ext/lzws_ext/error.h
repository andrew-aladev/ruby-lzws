// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_ERROR_H)
#define LZWS_EXT_ERROR_H

#include "lzws_ext/common.h"
#include "ruby.h"

// Results for errors listed in "lib/lzws/error" used in c extension.

enum
{
  LZWS_EXT_ERROR_ALLOCATE_FAILED = 1,
  LZWS_EXT_ERROR_VALIDATE_FAILED,

  LZWS_EXT_ERROR_USED_AFTER_CLOSE,
  LZWS_EXT_ERROR_NOT_ENOUGH_SOURCE_BUFFER,
  LZWS_EXT_ERROR_NOT_ENOUGH_DESTINATION_BUFFER,
  LZWS_EXT_ERROR_DECOMPRESSOR_CORRUPTED_SOURCE,

  LZWS_EXT_ERROR_ACCESS_IO,
  LZWS_EXT_ERROR_READ_IO,
  LZWS_EXT_ERROR_WRITE_IO,

  LZWS_EXT_ERROR_UNEXPECTED
};

NORETURN(void lzws_ext_raise_error(lzws_ext_result_t ext_result));

#endif // LZWS_EXT_ERROR_H
