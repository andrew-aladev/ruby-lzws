# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "mkmf"

def require_header(name)
  abort "Can't find #{name} header" unless find_header name
end

require_header "lzws/buffer.h"
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

functions = %w[
  lzws_create_buffer_for_compressor
  lzws_create_buffer_for_decompressor
  lzws_resize_buffer

  lzws_compress_string
  lzws_decompress_string

  lzws_compress_file
  lzws_decompress_file

  lzws_compressor_write_magic_header
  lzws_compressor_get_initial_state
  lzws_compress
  lzws_flush_compressor
  lzws_compressor_free_state

  lzws_decompressor_read_magic_header
  lzws_decompressor_get_initial_state
  lzws_decompress
  lzws_decompressor_free_state
]
.freeze

require_library "lzws", functions

extension_name = "lzws_ext".freeze
dir_config extension_name

# rubocop:disable Style/GlobalVars
$srcs = %w[stream/compressor stream/decompressor error io main option string]
  .map { |name| "src/#{extension_name}/#{name}.c" }
  .freeze

$CFLAGS << " -Wno-declaration-after-statement"
$VPATH << "$(srcdir)/#{extension_name}:$(srcdir)/#{extension_name}/stream"
# rubocop:enable Style/GlobalVars

create_makefile extension_name
