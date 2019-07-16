# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/string"

require_relative "common"
require_relative "minitest"
require_relative "option"
require_relative "validation"

module LZWS
  module Test
    class String < Minitest::Unit::TestCase
      Target = LZWS::String

      NATIVE_SOURCE_PATH  = Common::NATIVE_SOURCE_PATH
      NATIVE_ARCHIVE_PATH = Common::NATIVE_ARCHIVE_PATH
      TEXTS               = Common::TEXTS
      ENCODINGS           = Common::ENCODINGS

      COMPATIBLE_OPTION_COMBINATIONS = Option::COMPATIBLE_OPTION_COMBINATIONS

      def test_invalid_arguments
        Validation::INVALID_STRINGS.each do |invalid_string|
          assert_raises ValidateError do
            Target.compress invalid_string
          end

          assert_raises ValidateError do
            Target.decompress invalid_string
          end
        end

        Option::INVALID_COMPRESSOR_OPTIONS.each do |invalid_options|
          assert_raises ValidateError do
            Target.compress "", invalid_options
          end
        end

        Option::INVALID_DECOMPRESSOR_OPTIONS.each do |invalid_options|
          assert_raises ValidateError do
            Target.decompress "", invalid_options
          end
        end
      end

      def test_texts
        TEXTS.each do |text|
          ENCODINGS.each do |encoding|
            encoded_text = text.dup.force_encoding encoding

            COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
              compressed_text = Target.compress encoded_text, compressor_options

              decompressed_text = Target.decompress compressed_text, decompressor_options
              decompressed_text.force_encoding encoding

              assert_equal encoded_text, decompressed_text
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
            compressed_text = ::File.read NATIVE_ARCHIVE_PATH

            decompressed_text = Target.decompress compressed_text
            decompressed_text.force_encoding encoding

            assert_equal encoded_text, decompressed_text

            # Native util is decompressing.

            compressed_text = Target.compress encoded_text
            ::File.write NATIVE_ARCHIVE_PATH, compressed_text
            Common.native_decompress NATIVE_ARCHIVE_PATH, NATIVE_SOURCE_PATH

            decompressed_text = ::File.read NATIVE_SOURCE_PATH
            decompressed_text.force_encoding encoding

            assert_equal encoded_text, decompressed_text
          end
        end
      end
    end

    Minitest << String
  end
end
