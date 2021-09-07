# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "mkmf"

have_func "rb_thread_call_without_gvl", "ruby/thread.h"

def require_header(name, constants: [], macroses: [], types: [], variables: [])
  abort "Can't find #{name} header" unless find_header name

  constants.each do |constant|
    abort "Can't find #{constant} constant in #{name} header" unless have_const constant, name
  end

  macroses.each do |macro|
    abort "Can't find #{macro} macro in #{name} header" unless have_macro macro, name
  end

  types.each do |type|
    abort "Can't find #{type} type in #{name} header" unless find_type type, nil, name
  end

  variables.each do |variable|
    abort "Can't find #{variable} variable in #{name} header" unless have_var variable, name
  end
end

require_header(
  "lzws/buffer.h",
  :macroses => %w[
    LZWS_DEFAULT_DESTINATION_BUFFER_LENGTH_FOR_COMPRESSOR
    LZWS_DEFAULT_DESTINATION_BUFFER_LENGTH_FOR_DECOMPRESSOR
    LZWS_DEFAULT_SOURCE_BUFFER_LENGTH_FOR_COMPRESSOR
    LZWS_DEFAULT_SOURCE_BUFFER_LENGTH_FOR_DECOMPRESSOR
  ]
)
require_header(
  "lzws/common.h",
  :constants => %w[
    LZWS_BIGGEST_MAX_CODE_BIT_LENGTH
    LZWS_LOWEST_MAX_CODE_BIT_LENGTH
  ],
  :types     => %w[
    lzws_byte_fast_t
    lzws_result_t
  ]
)
require_header(
  "lzws/compressor/common.h",
  :constants => %w[
    LZWS_COMPRESSOR_ALLOCATE_FAILED
    LZWS_COMPRESSOR_INVALID_MAX_CODE_BIT_LENGTH
    LZWS_COMPRESSOR_NEEDS_MORE_DESTINATION
  ],
  :types     => %w[lzws_compressor_options_t],
  :variables => %w[LZWS_COMPRESSOR_DEFAULT_OPTIONS]
)
require_header "lzws/compressor/main.h"
require_header(
  "lzws/compressor/state.h",
  :types => %w[lzws_compressor_state_t]
)
require_header(
  "lzws/config.h",
  :macroses => %w[LZWS_VERSION]
)
require_header(
  "lzws/decompressor/common.h",
  :constants => %w[
    LZWS_DECOMPRESSOR_ALLOCATE_FAILED
    LZWS_DECOMPRESSOR_CORRUPTED_SOURCE
    LZWS_DECOMPRESSOR_INVALID_MAGIC_HEADER
    LZWS_DECOMPRESSOR_INVALID_MAX_CODE_BIT_LENGTH
    LZWS_DECOMPRESSOR_NEEDS_MORE_DESTINATION
  ],
  :types     => %w[lzws_decompressor_options_t],
  :variables => %w[LZWS_DECOMPRESSOR_DEFAULT_OPTIONS]
)
require_header "lzws/decompressor/main.h"
require_header(
  "lzws/decompressor/state.h",
  :types => %w[lzws_decompressor_state_t]
)
require_header(
  "lzws/file.h",
  :constants => %w[
    LZWS_FILE_ALLOCATE_FAILED
    LZWS_FILE_DECOMPRESSOR_CORRUPTED_SOURCE
    LZWS_FILE_NOT_ENOUGH_DESTINATION_BUFFER
    LZWS_FILE_NOT_ENOUGH_SOURCE_BUFFER
    LZWS_FILE_READ_FAILED
    LZWS_FILE_VALIDATE_FAILED
    LZWS_FILE_WRITE_FAILED
  ]
)

def require_library(name, functions)
  functions.each do |function|
    abort "Can't find #{function} function in #{name} library" unless find_library name, function
  end
end

require_library(
  "lzws",
  %w[
    lzws_compress
    lzws_compress_file
    lzws_compressor_finish
    lzws_compressor_free_state
    lzws_compressor_get_initial_state
    lzws_create_source_buffer_for_compressor
    lzws_create_source_buffer_for_decompressor
    lzws_create_destination_buffer_for_compressor
    lzws_create_destination_buffer_for_decompressor
    lzws_decompress
    lzws_decompress_file
    lzws_decompressor_free_state
    lzws_decompressor_get_initial_state
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

if ENV["CI"]
  $CFLAGS << " --coverage"
  $LDFLAGS << " --coverage"
end

$CFLAGS << " -Wno-declaration-after-statement"

$VPATH << "$(srcdir)/#{extension_name}:$(srcdir)/#{extension_name}/stream"
# rubocop:enable Style/GlobalVars

create_makefile extension_name
