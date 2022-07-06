# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/test/stream/reader_helpers"
require "lzws/stream/reader"
require "lzws/string"

require_relative "../common"
require_relative "../minitest"
require_relative "../option"

module LZWS
  module Test
    module Stream
      class ReaderHelpers < ADSP::Test::Stream::ReaderHelpers
        Target = LZWS::Stream::Reader
        Option = Test::Option
        String = LZWS::String

        NATIVE_SOURCE_PATH  = Common::NATIVE_SOURCE_PATH
        NATIVE_ARCHIVE_PATH = Common::NATIVE_ARCHIVE_PATH

        def test_open_with_large_texts_and_native_compress
          Common.parallel LARGE_TEXTS do |text, worker_index|
            native_source_path  = Common.get_path NATIVE_SOURCE_PATH, worker_index
            native_archive_path = Common.get_path NATIVE_ARCHIVE_PATH, worker_index

            ::File.write native_source_path, text, :mode => "wb"
            Common.native_compress native_source_path, native_archive_path

            decompressed_text = Target.open native_archive_path, &:read
            decompressed_text.force_encoding text.encoding

            assert_equal text, decompressed_text
          end
        end
      end

      Minitest << ReaderHelpers
    end
  end
end
