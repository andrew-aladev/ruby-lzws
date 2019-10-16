// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/option.h"

#include <stdbool.h>

#include "lzws_ext/error.h"
#include "ruby.h"

static inline VALUE get_raw_option_value(VALUE options, const char* name)
{
  return rb_funcall(options, rb_intern("[]"), 1, ID2SYM(rb_intern(name)));
}

bool lzws_ext_get_bool_option_value(VALUE options, const char* name)
{
  VALUE raw_value = get_raw_option_value(options, name);

  int raw_type = TYPE(raw_value);
  if (raw_type != T_TRUE && raw_type != T_FALSE) {
    lzws_ext_raise_error(LZWS_EXT_ERROR_VALIDATE_FAILED);
  }

  return raw_type == T_TRUE;
}

unsigned int lzws_ext_get_uint_option_value(VALUE options, const char* name)
{
  VALUE raw_value = get_raw_option_value(options, name);

  Check_Type(raw_value, T_FIXNUM);

  return NUM2UINT(raw_value);
}

unsigned long lzws_ext_get_ulong_option_value(VALUE options, const char* name)
{
  VALUE raw_value = get_raw_option_value(options, name);

  Check_Type(raw_value, T_FIXNUM);

  return NUM2ULONG(raw_value);
}
