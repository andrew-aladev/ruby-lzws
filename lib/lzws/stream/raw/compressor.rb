# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/stream/raw/compressor"
require "lzws_ext"

require_relative "../../option"
require_relative "../../validation"

module LZWS
  module Stream
    module Raw
      # LZWS::Stream::Raw::Compressor class.
      class Compressor < ADSP::Stream::Raw::Compressor
        # Current native compressor class.
        NativeCompressor = Stream::NativeCompressor

        # Current option class.
        Option = LZWS::Option

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
