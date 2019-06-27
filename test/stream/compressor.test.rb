# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/compressor"

require_relative "../common"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Test
    module Stream
      class Compressor < Minitest::Unit::TestCase
        Target = LZWS::Stream::Compressor
      end

      Minitest << Compressor
    end
  end
end
