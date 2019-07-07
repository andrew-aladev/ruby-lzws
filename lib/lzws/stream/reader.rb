# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "abstract_io"
require_relative "decompressor"
require_relative "../validation"

module LZWS
  module Stream
    class Reader < AbstractIO
      def initialize(source_io, options, *args)
        decompressor = Decompressor.new options

        super source_io, decompressor, *args
      end

      # each_byte
      # eof?
      # read
      # read_nonblock
      # getbyte
      # ungetbyte
    end
  end
end
