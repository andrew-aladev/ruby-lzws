// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_GVL_H)
#define LZWS_EXT_GVL_H

#if defined(HAVE_RB_THREAD_CALL_WITHOUT_GVL)

#include "ruby/thread.h"

#define LZWS_EXT_GVL_WRAP(gvl, function, data)                             \
  if (gvl) {                                                               \
    function((void*) data);                                                \
  } else {                                                                 \
    rb_thread_call_without_gvl(function, (void*) data, RUBY_UBF_IO, NULL); \
  }

#else

#define LZWS_EXT_GVL_WRAP(_gvl, function, data) function((void*) data);

#endif // HAVE_RB_THREAD_CALL_WITHOUT_GVL

#endif // LZWS_EXT_GVL_H
