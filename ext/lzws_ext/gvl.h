// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_GVL_H)
#define LZWS_EXT_GVL_H

#ifdef HAVE_RB_THREAD_CALL_WITHOUT_GVL

#include "ruby/thread.h"

#define LZWS_EXT_GVL_WRAP(with_gvl, function, data)                        \
  if (with_gvl) {                                                          \
    function((void*) data);                                                \
  } else {                                                                 \
    rb_thread_call_without_gvl(function, (void*) data, RUBY_UBF_IO, NULL); \
  }

#else

#define LZWS_EXT_GVL_WRAP(_with_gvl, function, data) function((void*) data);

#endif

#endif // LZWS_EXT_GVL_H
