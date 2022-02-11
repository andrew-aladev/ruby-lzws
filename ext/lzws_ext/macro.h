// Ruby bindings for lzws library.
// Copyright (c) 2019 AUTHORS, MIT License.

#if !defined(LZWS_EXT_MACRO_H)
#define LZWS_EXT_MACRO_H

#if defined(__GNUC__)
#define LZWS_EXT_UNUSED(x) x __attribute__((__unused__))
#else
#define LZWS_EXT_UNUSED(x) x
#endif // __GNUC__

#endif // LZWS_EXT_MACRO_H
