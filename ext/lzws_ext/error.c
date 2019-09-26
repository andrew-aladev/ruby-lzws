// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/error.h"

#include "lzws_ext/common.h"
#include "ruby.h"

static inline NORETURN(void raise(const char* name, const char* description))
{
  VALUE module = rb_define_module(LZWS_EXT_MODULE_NAME);
  VALUE error  = rb_const_get(module, rb_intern(name));
  rb_raise(error, "%s", description);
}

void lzws_ext_raise_error(lzws_ext_result_t result)
{
  switch (result) {
    case LZWS_EXT_ERROR_ALLOCATE_FAILED:
      raise("AllocateError", "allocate error");
    case LZWS_EXT_ERROR_VALIDATE_FAILED:
      raise("ValidateError", "validate error");

    case LZWS_EXT_ERROR_USED_AFTER_CLOSE:
      raise("UsedAfterCloseError", "used after closed");
    case LZWS_EXT_ERROR_NOT_ENOUGH_SOURCE_BUFFER:
      raise("NotEnoughSourceBufferError", "not enough source buffer");
    case LZWS_EXT_ERROR_NOT_ENOUGH_DESTINATION_BUFFER:
      raise("NotEnoughDestinationBufferError", "not enough destination buffer");
    case LZWS_EXT_ERROR_DECOMPRESSOR_CORRUPTED_SOURCE:
      raise("DecompressorCorruptedSourceError", "decompressor received corrupted source");

    case LZWS_EXT_ERROR_ACCESS_IO:
      raise("AccessIOError", "failed to access IO");
    case LZWS_EXT_ERROR_READ_IO:
      raise("ReadIOError", "failed to read IO");
    case LZWS_EXT_ERROR_WRITE_IO:
      raise("WriteIOError", "failed to write IO");

    default:
      // LZWS_EXT_ERROR_UNEXPECTED
      raise("UnexpectedError", "unexpected error");
  }
}
