// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/error.h"

static inline NORETURN(void raise_error(const char* name, const char* description))
{
  VALUE module = rb_define_module(LZWS_EXT_MODULE_NAME);
  VALUE error  = rb_const_get(module, rb_intern(name));
  rb_raise(error, "%s", description);
}

void lzws_ext_raise_error(lzws_ext_result_t ext_result)
{
  switch (ext_result) {
    case LZWS_EXT_ERROR_ALLOCATE_FAILED:
      raise_error("AllocateError", "allocate error");
    case LZWS_EXT_ERROR_VALIDATE_FAILED:
      raise_error("ValidateError", "validate error");

    case LZWS_EXT_ERROR_USED_AFTER_CLOSE:
      raise_error("UsedAfterCloseError", "used after closed");
    case LZWS_EXT_ERROR_NOT_ENOUGH_SOURCE_BUFFER:
      raise_error("NotEnoughSourceBufferError", "not enough source buffer");
    case LZWS_EXT_ERROR_NOT_ENOUGH_DESTINATION_BUFFER:
      raise_error("NotEnoughDestinationBufferError", "not enough destination buffer");
    case LZWS_EXT_ERROR_DECOMPRESSOR_CORRUPTED_SOURCE:
      raise_error("DecompressorCorruptedSourceError", "decompressor received corrupted source");

    case LZWS_EXT_ERROR_ACCESS_IO:
      raise_error("AccessIOError", "failed to access IO");
    case LZWS_EXT_ERROR_READ_IO:
      raise_error("ReadIOError", "failed to read IO");
    case LZWS_EXT_ERROR_WRITE_IO:
      raise_error("WriteIOError", "failed to write IO");

    default:
      // LZWS_EXT_ERROR_UNEXPECTED
      raise_error("UnexpectedError", "unexpected error");
  }
}
