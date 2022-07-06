# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/test/stream/writer"
require "lzws/stream/writer"
require "lzws/string"

require_relative "../minitest"
require_relative "../option"

module LZWS
  module Test
    module Stream
      class Writer < ADSP::Test::Stream::Writer
        Target = LZWS::Stream::Writer
        Option = Test::Option
        String = LZWS::String
      end

      Minitest << Writer
    end
  end
end
