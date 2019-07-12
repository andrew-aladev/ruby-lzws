# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "abstract"
require_relative "raw/decompressor"

module LZWS
  module Stream
    class Reader < Abstract
      def initialize(source_io, options = {}, *args)
        @options = options

        super source_io, *args
      end

      def create_raw_stream
        Raw::Decompressor.new @options
      end
    end
  end
end
