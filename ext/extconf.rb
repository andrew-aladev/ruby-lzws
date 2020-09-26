# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "mkmf"

def require_header(name, types = [])
  abort "Can't find #{name} header" unless find_header name

  types.each do |type|
    abort "Can't find #{type} type in #{name} header" unless find_type type, nil, name
  end
end

require_header "lzws/buffer.h"
require_header "lzws/common.h", %w[lzws_result_t]
require_header "lzws/compressor/common.h"
require_header "lzws/compressor/main.h"
require_header "lzws/compressor/state.h", %w[lzws_compressor_state_t]
require_header "lzws/decompressor/common.h"
require_header "lzws/decompressor/main.h"
require_header "lzws/decompressor/state.h", %w[lzws_decompressor_state_t]
require_header "lzws/file.h"

def require_library(name, functions)
  functions.each do |function|
    abort "Can't find #{function} function in #{name} library" unless find_library name, function
  end
end

require_library(
  "lzws",
  %w[
    lzws_create_source_buffer_for_compressor
    lzws_create_destination_buffer_for_compressor
    lzws_create_source_buffer_for_decompressor
    lzws_create_destination_buffer_for_decompressor

    lzws_compressor_get_initial_state
    lzws_compressor_free_state
    lzws_compress
    lzws_compressor_finish

    lzws_decompressor_get_initial_state
    lzws_decompressor_free_state
    lzws_decompress

    lzws_compress_file
    lzws_decompress_file
  ]
)

extension_name = "lzws_ext".freeze
dir_config extension_name

# rubocop:disable Style/GlobalVars
$srcs = %w[
  stream/compressor
  stream/decompressor
  buffer
  error
  io
  main
  option
  string
]
.map { |name| "src/#{extension_name}/#{name}.c" }
.freeze

# Removing library duplicates.
$libs = $libs.split(%r{\s})
  .reject(&:empty?)
  .sort
  .uniq
  .join " "

if ENV["CI"] || ENV["COVERAGE"]
  $CFLAGS << " --coverage"
  $LDFLAGS << " --coverage"
end

$CFLAGS << " -Wno-declaration-after-statement"

$VPATH << "$(srcdir)/#{extension_name}:$(srcdir)/#{extension_name}/stream"
# rubocop:enable Style/GlobalVars

create_makefile extension_name
