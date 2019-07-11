# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/reader"

require_relative "abstract"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Test
    module Stream
      class Reader < Abstract
        Target = LZWS::Stream::Reader
      end

      Minitest << Reader
    end
  end
end
