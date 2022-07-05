# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/test/string"
require "lzws/string"

require_relative "common"
require_relative "minitest"
require_relative "option"

module LZWS
  module Test
    class String < ADSP::Test::String
      Target = LZWS::String
      Option = LZWS::Test::Option

      NATIVE_SOURCE_PATH  = Common::NATIVE_SOURCE_PATH
      NATIVE_ARCHIVE_PATH = Common::NATIVE_ARCHIVE_PATH

      def test_invalid_text
        corrupted_compressed_text = "#{Target.compress('1111')}1111".b

        assert_raises DecompressorCorruptedSourceError do
          Target.decompress corrupted_compressed_text
        end
      end

      def test_large_texts_and_native_compress
        Common.parallel LARGE_TEXTS do |text, worker_index|
          native_source_path  = Common.get_path NATIVE_SOURCE_PATH, worker_index
          native_archive_path = Common.get_path NATIVE_ARCHIVE_PATH, worker_index

          ::File.write native_source_path, text, :mode => "wb"
          Common.native_compress native_source_path, native_archive_path
          compressed_text = ::File.read native_archive_path, :mode => "rb"

          decompressed_text = Target.decompress compressed_text
          decompressed_text.force_encoding text.encoding

          assert_equal text, decompressed_text

          compressed_text = Target.compress text
          ::File.write native_archive_path, compressed_text, :mode => "wb"
          Common.native_decompress native_archive_path, native_source_path

          decompressed_text = ::File.read native_source_path, :mode => "rb"
          decompressed_text.force_encoding text.encoding

          assert_equal text, decompressed_text
        end
      end
    end

    Minitest << String
  end
end
