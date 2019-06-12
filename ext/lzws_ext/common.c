// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "common.h"
#include "ruby.h"

VALUE lzws_ext_get_option(VALUE options, const char* name)
{
  VALUE name_symbol = ID2SYM(rb_intern(name));
  return rb_funcall(options, rb_intern("[]"), 1, name_symbol);
}

void lzws_ext_check_bool_type(VALUE option, const char* name)
{
  int type = TYPE(option);

  if (type != T_TRUE && type != T_FALSE) {
    VALUE message = rb_sprintf("wrong value for \"%s\" (expected true or false)", name);
    rb_exc_raise(rb_exc_new_str(rb_eFatal, message));
  }
}
