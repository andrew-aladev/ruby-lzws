# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "../error"
require_relative "../option"

module LZWS
  module Stream
    class Compressor
      def initialize(reader, writer, options = {})
        options = Option.get_compressor_options options

        @native_compressor = NativeCompressor.new options

        @source = StringIO.new
        @source.set_encoding Encoding::BINARY
      end

      # proc.is_a? ::Proc or proc.is_a? Method or proc.is_a? UnboundMethod
    end
  end
end
