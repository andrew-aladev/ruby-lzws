# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/test/stream/minitar"
require "lzws/stream/reader"
require "lzws/stream/writer"

require_relative "../minitest"

module LZWS
  module Test
    module Stream
      class MinitarTest < ADSP::Test::Stream::MinitarTest
        Reader = LZWS::Stream::Reader
        Writer = LZWS::Stream::Writer
      end

      Minitest << MinitarTest
    end
  end
end
