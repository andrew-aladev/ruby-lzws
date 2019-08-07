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

      TRANSCODE_OPTIONS = {
        :invalid => :replace,
        :undef   => :replace,
        :replace => "?"
      }
      .freeze

      def self.generate_texts(*sources)
        sources.flat_map do |source|
          ENCODINGS.map do |encoding|
            source.encode encoding, TRANSCODE_OPTIONS
          end
        end
      end

      TEXTS = generate_texts(
        "",
        ::SecureRandom.random_bytes(1 << 9) # 512 B
      )
      .freeze

      LARGE_TEXTS = generate_texts(
        ::SecureRandom.random_bytes(1 << 20) # 1 MB
      )
      .freeze

      PORTION_LENGTHS = [
        1,
        256
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
