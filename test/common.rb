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

      [
        SOURCE_PATH,
        ARCHIVE_PATH,
        NATIVE_SOURCE_PATH,
        NATIVE_ARCHIVE_PATH
      ]
      .each { |path| FileUtils.touch path }

      PORT = 54_001

      ENCODINGS = %w[
        binary
        UTF-8
        UTF-16LE
      ]
      .map { |encoding_name| ::Encoding.find encoding_name }
      .freeze

      TEXTS = [
        "",
        "tobeornottobeortobeornot",
        ::SecureRandom.random_bytes(1 << 12) # 4 KB
      ]
      .flat_map do |text|
        ENCODINGS.map do |encoding|
          text.encode(
            encoding,
            :invalid => :replace,
            :undef   => :replace,
            :replace => "?"
          )
        end
      end
      .freeze

      PORTION_LENGTHS = [
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
