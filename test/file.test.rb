# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/file"

require_relative "common"
require_relative "minitest"
require_relative "option"
require_relative "validation"

module LZWS
  module Test
    class File < Minitest::Unit::TestCase
      Target = LZWS::File

      SOURCE_PATH         = Common::SOURCE_PATH
      ARCHIVE_PATH        = Common::ARCHIVE_PATH
      NATIVE_SOURCE_PATH  = Common::NATIVE_SOURCE_PATH
      NATIVE_ARCHIVE_PATH = Common::NATIVE_ARCHIVE_PATH
      TEXTS               = Common::TEXTS
      LARGE_TEXTS         = Common::LARGE_TEXTS

      def test_invalid_arguments
        Validation::INVALID_STRINGS.each do |invalid_path|
          assert_raises ValidateError do
            Target.compress invalid_path, ARCHIVE_PATH
          end

          assert_raises ValidateError do
            Target.compress SOURCE_PATH, invalid_path
          end

          assert_raises ValidateError do
            Target.decompress invalid_path, SOURCE_PATH
          end

          assert_raises ValidateError do
            Target.decompress ARCHIVE_PATH, invalid_path
          end
        end

        Option::INVALID_COMPRESSOR_OPTIONS.each do |invalid_options|
          assert_raises ValidateError do
            Target.compress SOURCE_PATH, ARCHIVE_PATH, invalid_options
          end
        end

        Option::INVALID_DECOMPRESSOR_OPTIONS.each do |invalid_options|
          assert_raises ValidateError do
            Target.decompress ARCHIVE_PATH, SOURCE_PATH, invalid_options
          end
        end
      end

      def test_texts
        TEXTS.each do |text|
          ::File.write SOURCE_PATH, text

          Option::COMPRESSOR_OPTION_COMBINATIONS.each do |compressor_options|
            Target.compress SOURCE_PATH, ARCHIVE_PATH, compressor_options

            Option.get_compatible_decompressor_options(compressor_options) do |decompressor_options|
              Target.decompress ARCHIVE_PATH, SOURCE_PATH, decompressor_options

              decompressed_text = ::File.read SOURCE_PATH
              decompressed_text.force_encoding text.encoding

              assert_equal text, decompressed_text
            end
          end
        end
      end

      def test_native_compress
        LARGE_TEXTS.each do |text|
          ::File.write NATIVE_SOURCE_PATH, text
          Common.native_compress NATIVE_SOURCE_PATH, NATIVE_ARCHIVE_PATH
          Target.decompress NATIVE_ARCHIVE_PATH, SOURCE_PATH

          decompressed_text = ::File.read SOURCE_PATH
          decompressed_text.force_encoding text.encoding
          assert_equal text, decompressed_text

          ::File.write SOURCE_PATH, text
          Target.compress SOURCE_PATH, ARCHIVE_PATH
          Common.native_decompress ARCHIVE_PATH, NATIVE_SOURCE_PATH

          decompressed_text = ::File.read NATIVE_SOURCE_PATH
          decompressed_text.force_encoding text.encoding
          assert_equal text, decompressed_text
        end
      end
    end

    Minitest << File
  end
end
