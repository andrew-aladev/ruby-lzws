# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/io/reader"

require_relative "abstract"
require_relative "../../minitest"
require_relative "../../option"
require_relative "../../validation"

module LZWS
  module Test
    module Stream
      module IO
        class Reader < Abstract
          Target = LZWS::Stream::IO::Reader
        end

        Minitest << Reader
      end
    end
  end
end
