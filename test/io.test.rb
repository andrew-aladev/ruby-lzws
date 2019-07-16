# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/io"

require_relative "common"
require_relative "minitest"
require_relative "option"
require_relative "validation"

module LZWS
  module Test
    class IO < Minitest::Unit::TestCase
      Target = LZWS::IO

      NATIVE_SOURCE_PATH  = Common::NATIVE_SOURCE_PATH
      NATIVE_ARCHIVE_PATH = Common::NATIVE_ARCHIVE_PATH
      TEXTS               = Common::TEXTS
      ENCODINGS           = Common::ENCODINGS

      COMPATIBLE_OPTION_COMBINATIONS = Option::COMPATIBLE_OPTION_COMBINATIONS

      def test_invalid_arguments
        ::IO.pipe do |read_io, write_io|
          Validation::INVALID_IOS.each do |invalid_io|
            assert_raises ValidateError do
              Target.compress invalid_io, write_io
            end

            assert_raises ValidateError do
              Target.compress read_io, invalid_io
            end

            assert_raises ValidateError do
              Target.decompress invalid_io, write_io
            end

            assert_raises ValidateError do
              Target.decompress read_io, invalid_io
            end
          end

          Option::INVALID_COMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises ValidateError do
              Target.compress read_io, write_io, invalid_options
            end
          end

          Option::INVALID_DECOMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises ValidateError do
              Target.decompress read_io, write_io, invalid_options
            end
          end
        end
      end

      def test_texts
        TEXTS.each do |text|
          ENCODINGS.each do |encoding|
            encoded_text = text.dup.force_encoding encoding

            COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
              ::IO.pipe("#{encoding}:#{Encoding::BINARY}") do |source_read_io, source_write_io|
                source_write_io << encoded_text
                source_write_io.close

                ::IO.pipe("#{Encoding::BINARY}:#{Encoding::BINARY}") do |compressed_read_io, compressed_write_io|
                  Target.compress source_read_io, compressed_write_io, compressor_options
                  compressed_write_io.close

                  ::IO.pipe("#{Encoding::BINARY}:#{encoding}") do |decompressed_read_io, decompressed_write_io|
                    Target.decompress compressed_read_io, decompressed_write_io, decompressor_options
                    decompressed_write_io.close

                    decompressed_text = decompressed_read_io.read
                    decompressed_text.force_encoding encoding

                    assert_equal encoded_text, decompressed_text
                  end
                end
              end
            end
          end
        end
      end

      def test_native_compress
        # Default options should be compatible with native util.

        TEXTS.each do |text|
          ENCODINGS.each do |encoding|
            encoded_text = text.dup.force_encoding encoding

            # Native util is compressing.

            ::File.write NATIVE_SOURCE_PATH, encoded_text
            Common.native_compress NATIVE_SOURCE_PATH, NATIVE_ARCHIVE_PATH

            ::IO.pipe("#{Encoding::BINARY}:#{encoding}") do |decompressed_read_io, decompressed_write_io|
              ::File.open(NATIVE_ARCHIVE_PATH, "rb") do |native_archive|
                Target.decompress native_archive, decompressed_write_io
                decompressed_write_io.close
              end

              decompressed_text = decompressed_read_io.read
              decompressed_text.force_encoding encoding

              assert_equal encoded_text, decompressed_text
            end

            # Native util is decompressing.

            ::IO.pipe("#{encoding}:#{Encoding::BINARY}") do |source_read_io, source_write_io|
              source_write_io << encoded_text
              source_write_io.close

              ::IO.pipe("#{Encoding::BINARY}:#{Encoding::BINARY}") do |compressed_read_io, compressed_write_io|
                Target.compress source_read_io, compressed_write_io
                compressed_write_io.close

                ::File.write NATIVE_ARCHIVE_PATH, compressed_read_io.read
                Common.native_decompress NATIVE_ARCHIVE_PATH, NATIVE_SOURCE_PATH

                decompressed_text = ::File.read NATIVE_SOURCE_PATH
                decompressed_text.force_encoding encoding

                assert_equal encoded_text, decompressed_text
              end
            end
          end
        end
      end
    end

    Minitest << IO
  end
end
