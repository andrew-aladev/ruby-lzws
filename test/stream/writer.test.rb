# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/writer"

require_relative "../minitest"

module LZWS
  module Test
    module Stream
      class Writer < Minitest::Unit::TestCase
        Target = LZWS::Stream::Writer

        def test_invalid_initialize
        end
      end

      Minitest << Writer
    end
  end
end
