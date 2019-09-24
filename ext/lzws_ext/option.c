// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/option.h"

#include <stdbool.h>

#include "lzws_ext/error.h"
#include "ruby.h"

static inline VALUE get_option(VALUE options, const char* name)
{
  return rb_funcall(options, rb_intern("[]"), 1, ID2SYM(rb_intern(name)));
}

unsigned long lzws_ext_get_fixnum_option(VALUE options, const char* name)
{
  VALUE value = get_option(options, name);

  Check_Type(value, T_FIXNUM);

  return NUM2UINT(value);
}

bool lzws_ext_get_bool_option(VALUE options, const char* name)
{
  VALUE value = get_option(options, name);

  int type = TYPE(value);
  if (type != T_TRUE && type != T_FALSE) {
    lzws_ext_raise_error(LZWS_EXT_ERROR_VALIDATE_FAILED);
  }

  return type == T_TRUE;
}
