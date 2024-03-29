# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/stream/raw/decompressor"
require "lzws_ext"

require_relative "../../option"
require_relative "../../validation"

module LZWS
  module Stream
    module Raw
      # LZWS::Stream::Raw::Decompressor class.
      class Decompressor < ADSP::Stream::Raw::Decompressor
        # Current native decompressor class.
        NativeDecompressor = Stream::NativeDecompressor

        # Current option class.
        Option = LZWS::Option

        # Flushes raw stream and writes next result using +writer+ proc.
        def flush(&writer)
          do_not_use_after_close

          Validation.validate_proc writer

          write_result(&writer)

          nil
        end
      end
    end
  end
end
