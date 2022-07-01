# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/stream/writer"

require_relative "raw/compressor"

module LZWS
  module Stream
    # LZWS::Stream::Writer class.
    class Writer < ADSP::Stream::Writer
      # Current raw stream class.
      RawCompressor = Raw::Compressor
    end
  end
end
