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
      LARGE_TEXTS         = Common::LARGE_TEXTS

      BUFFER_LENGTH_NAMES   = %i[destination_buffer_length].freeze
      BUFFER_LENGTH_MAPPING = { :destination_buffer_length => :destination_buffer_length }.freeze

      def test_invalid_arguments
        Validation::INVALID_STRINGS.each do |invalid_string|
          assert_raises ValidateError do
            Target.compress invalid_string
          end

          assert_raises ValidateError do
            Target.decompress invalid_string
          end
        end

        get_invalid_compressor_options do |invalid_options|
          assert_raises ValidateError do
            Target.compress "", invalid_options
          end
        end

        get_invalid_decompressor_options do |invalid_options|
          assert_raises ValidateError do
            Target.decompress "", invalid_options
          end
        end
      end

      def test_invalid_text
        corrupted_compressed_text = Target.compress("1111") + "1111"

        assert_raises DecompressorCorruptedSourceError do
          Target.decompress corrupted_compressed_text
        end
      end

      def test_texts
        TEXTS.each do |text|
          get_compressor_options do |compressor_options|
            compressed_text = Target.compress text, compressor_options

            get_compatible_decompressor_options(compressor_options) do |decompressor_options|
              decompressed_text = Target.decompress compressed_text, decompressor_options
              decompressed_text.force_encoding text.encoding

              assert_equal text, decompressed_text
            end
          end
        end
      end

      def test_large_texts_and_native_compress
        LARGE_TEXTS.each do |text|
          ::File.write NATIVE_SOURCE_PATH, text
          Common.native_compress NATIVE_SOURCE_PATH, NATIVE_ARCHIVE_PATH
          compressed_text = ::File.read NATIVE_ARCHIVE_PATH

          decompressed_text = Target.decompress compressed_text
          decompressed_text.force_encoding text.encoding

          assert_equal text, decompressed_text

          compressed_text = Target.compress text
          ::File.write NATIVE_ARCHIVE_PATH, compressed_text
          Common.native_decompress NATIVE_ARCHIVE_PATH, NATIVE_SOURCE_PATH

          decompressed_text = ::File.read NATIVE_SOURCE_PATH
          decompressed_text.force_encoding text.encoding

          assert_equal text, decompressed_text
        end
      end

      # -----

      def get_invalid_compressor_options(&block)
        Option.get_invalid_compressor_options BUFFER_LENGTH_NAMES, &block
      end

      def get_invalid_decompressor_options(&block)
        Option.get_invalid_decompressor_options BUFFER_LENGTH_NAMES, &block
      end

      def get_compressor_options(&block)
        Option.get_compressor_options BUFFER_LENGTH_NAMES, &block
      end

      def get_compatible_decompressor_options(compressor_options, &block)
        Option.get_compatible_decompressor_options compressor_options, BUFFER_LENGTH_MAPPING, &block
      end
    end

    Minitest << String
  end
end
