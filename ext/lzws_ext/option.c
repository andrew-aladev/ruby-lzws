// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include <stdbool.h>

#include "ruby.h"

#include "lzws_ext/error.h"
#include "lzws_ext/option.h"

static inline VALUE get_option(VALUE options, const char *name)
{
  return rb_funcall(options, rb_intern("[]"), 1, ID2SYM(rb_intern(name)));
}

unsigned long lzws_ext_get_fixnum_option(VALUE options, const char *name)
{
  VALUE value = get_option(options, name);

  Check_Type(value, T_FIXNUM);

  return rb_num2uint(value);
}

bool lzws_ext_get_bool_option(VALUE options, const char *name)
{
  VALUE value = get_option(options, name);

  int type = TYPE(value);
  if (type != T_TRUE && type != T_FALSE) {
    lzws_ext_raise_error("ValidateError", "invalid bool value");
  }

  return type == T_TRUE;
}
