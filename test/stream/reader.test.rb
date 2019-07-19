# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/reader"

require_relative "abstract"
require_relative "../common"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Test
    module Stream
      class Reader < Abstract
        Target = LZWS::Stream::Reader

        ARCHIVE_PATH      = Common::ARCHIVE_PATH
        TEXTS             = Common::TEXTS
        ENCODINGS         = Common::ENCODINGS
        PORTION_BYTESIZES = Common::PORTION_BYTESIZES

        COMPATIBLE_OPTION_COMBINATIONS = Option::COMPATIBLE_OPTION_COMBINATIONS

        def test_invalid_initialize
          Option::INVALID_DECOMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises ValidateError do
              target.new STDOUT, invalid_options
            end
          end

          super
        end
      end

      Minitest << Reader
    end
  end
end
