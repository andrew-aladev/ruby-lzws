# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "../option"
require_relative "../validation"

module LZWS
  module Stream
    class Compressor
      def initialize(reader, writer, options = {})
        Validation.validate_proc reader
        Validation.validate_proc writer

        options = Option.get_compressor_options options

        @native_compressor = NativeCompressor.new options
      end
    end
  end
end
