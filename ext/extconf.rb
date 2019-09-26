# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "mkmf"

def require_header(name)
  abort "Can't find #{name} header" unless find_header name
end

require_header "lzws/buffer.h"
require_header "lzws/compressor/common.h"
require_header "lzws/compressor/main.h"
require_header "lzws/compressor/state.h"
require_header "lzws/decompressor/common.h"
require_header "lzws/decompressor/main.h"
require_header "lzws/decompressor/state.h"
require_header "lzws/file.h"

def require_library(name, functions)
  functions.each do |function|
    abort "Can't find #{name} library and #{function} function" unless find_library name, function
  end
end

functions = %w[
  lzws_create_buffer_for_compressor
  lzws_create_buffer_for_decompressor
  lzws_resize_buffer

  lzws_compress_file
  lzws_decompress_file

  lzws_compressor_get_initial_state
  lzws_compressor_free_state
  lzws_compress
  lzws_compressor_finish

  lzws_decompressor_get_initial_state
  lzws_decompressor_free_state
  lzws_decompress
]
.freeze

require_library "lzws", functions

extension_name = "lzws_ext".freeze
dir_config extension_name

sources = %w[
  stream/compressor
  stream/decompressor
  error
  io
  main
  option
  string
]
.freeze

# rubocop:disable Style/GlobalVars
$srcs = sources
  .map { |name| "src/#{extension_name}/#{name}.c" }
  .freeze

$CFLAGS << " -Wno-declaration-after-statement"
$VPATH << "$(srcdir)/#{extension_name}:$(srcdir)/#{extension_name}/stream"
# rubocop:enable Style/GlobalVars

create_makefile extension_name
