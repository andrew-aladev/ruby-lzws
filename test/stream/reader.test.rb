# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/reader"

require_relative "../minitest"

module LZWS
  module Test
    module Stream
      class Reader < Minitest::Unit::TestCase
        Target = LZWS::Stream::Reader

        def test_invalid_initialize
        end
      end

      Minitest << Reader
    end
  end
end
