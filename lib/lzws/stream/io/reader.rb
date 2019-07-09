# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "abstract"
require_relative "../processor/decompressor"
require_relative "../../validation"

module LZWS
  module Stream
    module IO
      class Reader < Abstract
        def initialize(source_io, options = {}, *args)
          decompressor = Processor::Decompressor.new options

          super decompressor, source_io, *args
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
end
