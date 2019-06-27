# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "option"
require_relative "validation"

module LZWS
  module IO
    def self.compress(source, destination, options = {})
      Validation.validate_io source
      Validation.validate_io destination

      options = Option.get_compressor_options options

      LZWS._native_compress_io source, destination, options
    end

    def self.decompress(source, destination, options = {})
      Validation.validate_io source
      Validation.validate_io destination

      options = Option.get_decompressor_options options

      LZWS._native_decompress_io source, destination, options
    end
  end
end
