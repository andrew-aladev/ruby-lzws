# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "../common"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

require "lzws/stream/reader"
require "lzws/string"

module LZWS
  module Test
    module Stream
      class ReaderHelpers < Minitest::Unit::TestCase
        Target = LZWS::Stream::Reader
        String = LZWS::String

        ARCHIVE_PATH        = Common::ARCHIVE_PATH
        NATIVE_SOURCE_PATH  = Common::NATIVE_SOURCE_PATH
        NATIVE_ARCHIVE_PATH = Common::NATIVE_ARCHIVE_PATH
        TEXTS               = Common::TEXTS

        COMPATIBLE_OPTION_COMBINATIONS = Option::COMPATIBLE_OPTION_COMBINATIONS

        # -- byte --

        def test_invalid_ungetbyte
          instance = target.new ::STDIN

          Validation::INVALID_STRINGS.each do |invalid_string|
            assert_raises ValidateError do
              instance.ungetbyte invalid_string
            end
          end
        end

        def test_byte
          TEXTS.each do |text|
            COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
              write_archive text, compressor_options

              Target.open ARCHIVE_PATH, decompressor_options do |instance|
                byte = instance.getbyte
                instance.ungetbyte byte unless byte.nil?

                begin
                  byte = instance.readbyte
                  instance.ungetc byte
                rescue ::EOFError # rubocop:disable Lint/HandleExceptions
                  # ok
                end

                decompressed_text = "".b
                instance.each_byte { |current_byte| decompressed_text << current_byte }

                decompressed_text.force_encoding text.encoding
                assert_equal text, decompressed_text
              end
            end
          end
        end

        # -- char --

        def test_invalid_ungetc
          instance = target.new ::STDIN

          Validation::INVALID_STRINGS.each do |invalid_string|
            assert_raises ValidateError do
              instance.ungetc invalid_string
            end
          end
        end

        def test_char
          TEXTS.each do |text|
            COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
              write_archive text, compressor_options

              Target.open ARCHIVE_PATH, decompressor_options do |instance|
                char = instance.getc
                instance.ungetc char unless char.nil?

                begin
                  char = instance.readchar
                  instance.ungetc char
                rescue ::EOFError # rubocop:disable Lint/HandleExceptions
                  # ok
                end

                decompressed_text = "".b
                instance.each_char { |current_char| decompressed_text << current_char }

                decompressed_text.force_encoding text.encoding
                assert_equal text, decompressed_text
              end
            end
          end
        end

        # -- lines --

        # -- etc --

        def test_invalid_open
          Validation::INVALID_STRINGS.each do |invalid_string|
            assert_raises ValidateError do
              Target.open(invalid_string) {}
            end
          end

          # Proc is required.
          assert_raises ValidateError do
            Target.open ARCHIVE_PATH
          end
        end

        def test_open
          TEXTS.each do |text|
            COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
              write_archive text, compressor_options

              decompressed_text = Target.open ARCHIVE_PATH, decompressor_options, &:read
              decompressed_text.force_encoding text.encoding
              assert_equal text, decompressed_text
            end
          end
        end

        def test_native_compress
          TEXTS.each do |text|
            ::File.write NATIVE_SOURCE_PATH, text
            Common.native_compress NATIVE_SOURCE_PATH, NATIVE_ARCHIVE_PATH

            decompressed_text = Target.open NATIVE_ARCHIVE_PATH, &:read
            decompressed_text.force_encoding text.encoding
            assert_equal text, decompressed_text
          end
        end

        # -----

        protected def write_archive(text, compressor_options)
          compressed_text = String.compress text, compressor_options
          ::File.write ARCHIVE_PATH, compressed_text
        end

        protected def target
          self.class::Target
        end
      end

      Minitest << ReaderHelpers
    end
  end
end
