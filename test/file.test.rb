# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/file"
require "fileutils"

require_relative "common"
require_relative "minitest"
require_relative "option"
require_relative "validation"

module LZWS
  module Test
    class File < Minitest::Unit::TestCase
      Target = LZWS::File

      SOURCE_PATH       = ::File.join(Common::TEMP_PATH, "source.txt").freeze
      COMPRESSED_PATH   = ::File.join(Common::TEMP_PATH, "compressed.bin").freeze
      DECOMPRESSED_PATH = ::File.join(Common::TEMP_PATH, "decompressed.txt").freeze

      def test_invalid_arguments
        Validation::INVALID_STRINGS.each do |invalid_path|
          assert_raises ValidateError do
            Target.compress invalid_path, COMPRESSED_PATH
          end

          assert_raises ValidateError do
            Target.compress SOURCE_PATH, invalid_path
          end

          assert_raises ValidateError do
            Target.decompress invalid_path, DECOMPRESSED_PATH
          end

          assert_raises ValidateError do
            Target.decompress COMPRESSED_PATH, invalid_path
          end
        end

        Option::INVALID_COMPRESSOR_OPTIONS.each do |invalid_options|
          assert_raises ValidateError do
            Target.compress SOURCE_PATH, COMPRESSED_PATH, invalid_options
          end
        end

        Option::INVALID_DECOMPRESSOR_OPTIONS.each do |invalid_options|
          assert_raises ValidateError do
            Target.decompress COMPRESSED_PATH, DECOMPRESSED_PATH, invalid_options
          end
        end
      end

      def test_texts
        FileUtils.touch [SOURCE_PATH, COMPRESSED_PATH, DECOMPRESSED_PATH]

        Common::TEXTS.each do |text|
          Common::ENCODINGS.each do |encoding|
            encoded_text = text.dup.force_encoding encoding
            ::File.write SOURCE_PATH, encoded_text

            Option::COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
              Target.compress SOURCE_PATH, COMPRESSED_PATH, compressor_options
              Target.decompress COMPRESSED_PATH, DECOMPRESSED_PATH, decompressor_options

              decompressed_text = ::File.open DECOMPRESSED_PATH, "rb", &:read
              decompressed_text.force_encoding encoding

              assert_equal encoded_text, decompressed_text
            end
          end
        end
      end
    end

    Minitest << File
  end
end
