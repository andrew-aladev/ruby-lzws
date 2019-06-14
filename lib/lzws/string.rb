# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "error"
require_relative "option"

module LZWS
  module String
    def self.validate_arguments(source, options)
      raise UnexpectedArgumentError unless source.is_a?(::String) || options.is_a?(::Hash)
    end

    def self.compress(source, options = {})
      validate_arguments source, options

      options = Option::COMPRESSOR_DEFAULTS.merge options
      LZWS._compress_string source, options
    end

    def self.decompress(source, options = {})
      validate_arguments source, options

      options = Option::DECOMPRESSOR_DEFAULTS.merge options
      LZWS._decompress_string source, options
    end
  end
end
