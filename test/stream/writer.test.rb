# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/writer"

require_relative "../minitest"
require_relative "../option"
require_relative "../validation"
require_relative "abstract_io"

module LZWS
  module Test
    module Stream
      class Writer < AbstractIO
        Target = LZWS::Stream::Writer
      end

      Minitest << Writer
    end
  end
end
