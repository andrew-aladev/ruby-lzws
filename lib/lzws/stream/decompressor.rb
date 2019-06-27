# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "../error"
require_relative "../option"

module LZWS
  module Stream
    class Decompressor
      def initialize(options = {})
        options = Option.get_decompressor_options options

        @native_decompressor = NativeDecompressor.new options

        @source = StringIO.new
        @source.set_encoding Encoding::BINARY
      end
    end
  end
end
