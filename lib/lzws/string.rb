# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "option"
require_relative "validation"

require "lzws_ext"

module LZWS
  module String
    def self.compress(source, options = {})
      Validation.validate_string source

      options = Option.get_compressor_options options

      LZWS._native_compress_string source, options
    end

    def self.decompress(source, options = {})
      Validation.validate_string source

      options = Option.get_decompressor_options options

      LZWS._native_decompress_string source, options
    end
  end
end
