# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/io/writer"

require_relative "abstract"
require_relative "../../minitest"
require_relative "../../option"
require_relative "../../validation"

module LZWS
  module Test
    module Stream
      module IO
        class Writer < Abstract
          Target = LZWS::Stream::IO::Writer
        end

        Minitest << Writer
      end
    end
  end
end
