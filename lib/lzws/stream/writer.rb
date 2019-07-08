# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "abstract_io"
require_relative "compressor"
require_relative "../validation"

module LZWS
  module Stream
    class Writer < AbstractIO
      def initialize(destination_io, options = {}, *args)
        compressor = Compressor.new options

        super compressor, destination_io, *args
      end

      # write
      # write_nonblock
    end
  end
end
