# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "abstract"
require_relative "../option"

module LZWS
  module Stream
    class Compressor < Abstract
      def initialize(writer, options = {})
        options           = Option.get_compressor_options options
        native_compressor = NativeCompressor.new options

        super writer, native_compressor
      end

      protected def write_magic_header
        loop do
          need_more_destination = @native_compressor.write_magic_header

          if need_more_destination
            flush_destination_buffer
            next
          end

          break
        end

        nil
      end
    end
  end
end
