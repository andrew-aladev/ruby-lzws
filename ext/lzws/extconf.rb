# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "mkmf"

def require_header(name)
  abort "Can't find #{name} header" unless find_header name
end

require_header "lzws/string.h"
require_header "lzws/file.h"
require_header "lzws/compressor/common.h"
require_header "lzws/compressor/header.h"
require_header "lzws/compressor/main.h"
require_header "lzws/decompressor/common.h"
require_header "lzws/decompressor/header.h"
require_header "lzws/decompressor/main.h"

def require_library(name, functions)
  functions.each do |function|
    abort "Can't find #{name} library and #{function} function" unless find_library name, function
  end
end

string_functions = %w[
  lzws_compress_string
  lzws_decompress_string
]
file_functions = %w[
  lzws_compress_file
  lzws_decompress_file
]
generic_compressor_functions = %w[
  lzws_compressor_write_magic_header
  lzws_compressor_get_initial_state
  lzws_compress
  lzws_flush_compressor
  lzws_compressor_free_state
]
generic_decompressor_functions = %w[
  lzws_decompressor_read_magic_header
  lzws_decompressor_get_initial_state
  lzws_decompress
  lzws_decompressor_free_state
]

functions = string_functions + file_functions + generic_compressor_functions + generic_decompressor_functions
require_library "lzws", functions

create_makefile "lzws_ext"
