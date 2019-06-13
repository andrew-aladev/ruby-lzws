// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_ERROR_H)
#define LZWS_EXT_ERROR_H

#include "ruby.h"

NORETURN(void lzws_ext_raise_error(const char* name, const char* description));

#endif // LZWS_EXT_ERROR_H
