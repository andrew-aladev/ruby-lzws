# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/test/file"
require "lzws/file"

require_relative "common"
require_relative "minitest"
require_relative "option"

module LZWS
  module Test
    class File < ADSP::Test::File
      Target = LZWS::File
      Option = Test::Option

      SOURCE_PATH         = Common::SOURCE_PATH
      ARCHIVE_PATH        = Common::ARCHIVE_PATH
      NATIVE_SOURCE_PATH  = Common::NATIVE_SOURCE_PATH
      NATIVE_ARCHIVE_PATH = Common::NATIVE_ARCHIVE_PATH
      LARGE_TEXTS         = Common::LARGE_TEXTS

      def test_large_texts_and_native_compress
        Common.parallel LARGE_TEXTS do |text, worker_index|
          source_path         = Common.get_path SOURCE_PATH, worker_index
          archive_path        = Common.get_path ARCHIVE_PATH, worker_index
          native_source_path  = Common.get_path NATIVE_SOURCE_PATH, worker_index
          native_archive_path = Common.get_path NATIVE_ARCHIVE_PATH, worker_index

          ::File.write native_source_path, text, :mode => "wb"
          Common.native_compress native_source_path, native_archive_path
          Target.decompress native_archive_path, source_path

          decompressed_text = ::File.read source_path, :mode => "rb"
          decompressed_text.force_encoding text.encoding

          assert_equal text, decompressed_text

          ::File.write source_path, text, :mode => "wb"
          Target.compress source_path, archive_path
          Common.native_decompress archive_path, native_source_path

          decompressed_text = ::File.read native_source_path, :mode => "rb"
          decompressed_text.force_encoding text.encoding

          assert_equal text, decompressed_text
        end
      end
    end

    Minitest << File
  end
end
