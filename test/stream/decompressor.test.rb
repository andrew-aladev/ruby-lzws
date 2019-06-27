# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/decompressor"

require_relative "../common"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Test
    module Stream
      class Decompressor < Minitest::Unit::TestCase
        Target = LZWS::Stream::Decompressor
      end

      Minitest << Decompressor
    end
  end
end
