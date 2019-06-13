// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/error.h"
#include "lzws_ext/common.h"
#include "ruby.h"

void lzws_ext_raise_error(const char* name, const char* description)
{
  VALUE module = rb_define_module(LZWS_EXT_MODULE_NAME);
  VALUE error  = rb_const_get(module, rb_intern(name));
  rb_raise(error, description);
}
