# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

module LZWS
  module Stream
    class AbstractIO
      def initialize
        @buffer = StringIO.new
        @buffer.set_encoding Encoding::BINARY
      end
    end
  end
end
