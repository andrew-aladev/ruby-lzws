# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "securerandom"

module LZWS
  module Test
    module Common
      BASE_PATH = ::File.expand_path ::File.join(::File.dirname(__FILE__), "..").freeze
      TEMP_PATH = ::File.join(BASE_PATH, "tmp").freeze

      SOURCE_PATH  = ::File.join(TEMP_PATH, "source").freeze
      ARCHIVE_PATH = ::File.join(TEMP_PATH, "archive").freeze

      NATIVE_SOURCE_PATH  = ::File.join(TEMP_PATH, "native_source").freeze
      NATIVE_ARCHIVE_PATH = ::File.join(TEMP_PATH, "native_archive").freeze

      TEXTS = [
        "",
        "hello world",
        "tobeornottobeortobeornot",
        SecureRandom.random_bytes(1 << 13) # 8 KB
      ]
      .freeze

      ENCODINGS = %w[
        binary
        UTF-8
        UTF-16
      ]
      .map { |encoding_name| Encoding.find encoding_name }
      .freeze

      PORTION_BYTESIZES = [
        1,
        2,
        512
      ]
      .freeze

      def self.native_compress(source_path, destination_path)
        system "compress < \"#{source_path}\" > \"#{destination_path}\""
      end

      def self.native_decompress(source_path, destination_path)
        system "compress -d < \"#{source_path}\" > \"#{destination_path}\""
      end
    end
  end
end
