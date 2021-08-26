// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#include "lzws_ext/option.h"

#include "lzws_ext/error.h"

// -- values --

static inline VALUE get_raw_value(VALUE options, const char* name)
{
  return rb_funcall(options, rb_intern("[]"), 1, ID2SYM(rb_intern(name)));
}

static inline bool get_bool_value(VALUE raw_value)
{
  int raw_type = TYPE(raw_value);
  if (raw_type != T_TRUE && raw_type != T_FALSE) {
    lzws_ext_raise_error(LZWS_EXT_ERROR_VALIDATE_FAILED);
  }

  return raw_type == T_TRUE;
}

static inline unsigned int get_uint_value(VALUE raw_value)
{
  Check_Type(raw_value, T_FIXNUM);

  return NUM2UINT(raw_value);
}

static inline size_t get_size_value(VALUE raw_value)
{
  Check_Type(raw_value, T_FIXNUM);

  return NUM2SIZET(raw_value);
}

void lzws_ext_resolve_bool_option(VALUE options, bool* option, const char* name)
{
  VALUE raw_value = get_raw_value(options, name);
  if (raw_value != Qnil) {
    *option = get_bool_value(raw_value);
  }
}

void lzws_ext_resolve_max_code_bit_length_option(VALUE options, lzws_byte_fast_t* option, const char* name)
{
  VALUE raw_value = get_raw_value(options, name);
  if (raw_value != Qnil) {
    *option = get_uint_value(raw_value);
  }
}

bool lzws_ext_get_bool_option_value(VALUE options, const char* name)
{
  VALUE raw_value = get_raw_value(options, name);

  return get_bool_value(raw_value);
}

size_t lzws_ext_get_size_option_value(VALUE options, const char* name)
{
  VALUE raw_value = get_raw_value(options, name);

  return get_size_value(raw_value);
}

// -- exports --

void lzws_ext_option_exports(VALUE root_module)
{
  VALUE module = rb_define_module_under(root_module, "Option");

  rb_define_const(module, "LOWEST_MAX_CODE_BIT_LENGTH", UINT2NUM(LZWS_LOWEST_MAX_CODE_BIT_LENGTH));
  rb_define_const(module, "BIGGEST_MAX_CODE_BIT_LENGTH", UINT2NUM(LZWS_BIGGEST_MAX_CODE_BIT_LENGTH));
}
