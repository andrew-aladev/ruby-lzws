# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "error"
require_relative "option"

module LZWS
  module IO
    def self.validate_arguments(source, destination, options)
      raise UnexpectedArgumentError unless source.is_a?(::IO) || destination.is_a?(::IO) || options.is_a?(::Hash)
    end

    def self.compress(source, destination, options = {})
      validate_arguments source, destination, options

      options = Option::COMPRESSOR_DEFAULTS.merge options
      LZWS._compress_io source, destination, options
    end

    def self.decompress(source, destination, options = {})
      validate_arguments source, destination, options

      options = Option::DECOMPRESSOR_DEFAULTS.merge options
      LZWS._decompress_io source, destination, options
    end
  end
end
