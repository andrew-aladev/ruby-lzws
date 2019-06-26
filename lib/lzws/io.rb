# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "error"
require_relative "option"

module LZWS
  module IO
    def self.validate_arguments(source, destination)
      raise ValidateError unless source.is_a?(::IO) && destination.is_a?(::IO)
    end

    def self.compress(source, destination, options = {})
      validate_arguments source, destination

      options = Option.get_compressor_options options

      LZWS._compress_io source, destination, options
    end

    def self.decompress(source, destination, options = {})
      validate_arguments source, destination

      options = Option.get_decompressor_options options

      LZWS._decompress_io source, destination, options
    end
  end
end
