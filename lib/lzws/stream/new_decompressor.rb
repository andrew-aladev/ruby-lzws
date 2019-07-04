# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "abstract"
require_relative "../option"

module LZWS
  module Stream
    class Decompressor < Abstract
      def initialize(writer, options = {})
        options             = Option.get_decompressor_options options
        native_decompressor = NativeDecompressor.new options

        super writer, native_decompressor
      end
    end
  end
end
