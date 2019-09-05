# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/writer"
require "lzws/string"

require_relative "../common"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Test
    module Stream
      class WriterHelpers < Minitest::Unit::TestCase
        Target = LZWS::Stream::Writer
        String = LZWS::String

        ARCHIVE_PATH       = Common::ARCHIVE_PATH
        NATIVE_SOURCE_PATH = Common::NATIVE_SOURCE_PATH
        TEXTS              = Common::TEXTS
        LARGE_TEXTS        = Common::LARGE_TEXTS
        PORTION_LENGTHS    = Common::PORTION_LENGTHS

        def test_print
          TEXTS.each do |text|
            Option::COMPRESSOR_OPTION_COMBINATIONS.each do |compressor_options|
              Target.open ARCHIVE_PATH, compressor_options do |instance|
                $LAST_READ_LINE = text

                begin
                  instance.print
                ensure
                  $LAST_READ_LINE = nil
                end
              end

              compressed_text = ::File.read ARCHIVE_PATH

              Option.get_compatible_decompressor_options(compressor_options) do |decompressor_options|
                check_text text, compressed_text, decompressor_options
              end
            end

            # This part of test is for not empty texts only.
            next if text.empty?

            PORTION_LENGTHS.each do |portion_length|
              sources = get_sources text, portion_length

              field_separator  = " ".encode text.encoding
              record_separator = "\n".encode text.encoding

              target_text = "".encode text.encoding
              sources.each { |source| target_text << source + field_separator }
              target_text << record_separator

              Option::COMPRESSOR_OPTION_COMBINATIONS.each do |compressor_options|
                Target.open ARCHIVE_PATH, compressor_options do |instance|
                  $OUTPUT_FIELD_SEPARATOR  = field_separator
                  $OUTPUT_RECORD_SEPARATOR = record_separator

                  begin
                    instance.print(*sources)
                  ensure
                    $OUTPUT_FIELD_SEPARATOR  = nil
                    $OUTPUT_RECORD_SEPARATOR = nil
                  end
                end

                compressed_text = ::File.read ARCHIVE_PATH

                Option.get_compatible_decompressor_options(compressor_options) do |decompressor_options|
                  check_text target_text, compressed_text, decompressor_options
                end
              end
            end
          end
        end

        def test_printf
          TEXTS.each do |text|
            PORTION_LENGTHS.each do |portion_length|
              sources = get_sources text, portion_length

              Option::COMPRESSOR_OPTION_COMBINATIONS.each do |compressor_options|
                Target.open ARCHIVE_PATH, compressor_options do |instance|
                  sources.each { |source| instance.printf "%s", source }
                end

                compressed_text = ::File.read ARCHIVE_PATH

                Option.get_compatible_decompressor_options(compressor_options) do |decompressor_options|
                  check_text text, compressed_text, decompressor_options
                end
              end
            end
          end
        end

        def test_invalid_putc
          instance = target.new ::STDOUT

          Validation::INVALID_CHARS.each do |invalid_char|
            assert_raises ValidateError do
              instance.putc invalid_char
            end
          end
        end

        def test_putc
          TEXTS.each do |text|
            Option::COMPRESSOR_OPTION_COMBINATIONS.each do |compressor_options|
              Target.open ARCHIVE_PATH, compressor_options do |instance|
                # Putc should process numbers and strings.
                text.chars.map.with_index do |char, index|
                  if index.even?
                    instance.putc char.ord, :encoding => text.encoding
                  else
                    instance.putc char
                  end
                end
              end

              compressed_text = ::File.read ARCHIVE_PATH

              Option.get_compatible_decompressor_options(compressor_options) do |decompressor_options|
                check_text text, compressed_text, decompressor_options
              end
            end
          end
        end

        def test_puts
          TEXTS.each do |text|
            PORTION_LENGTHS.each do |portion_length|
              newline = "\n".encode text.encoding

              sources = get_sources text, portion_length
              sources = sources.map do |source|
                source.delete_suffix! newline while source.end_with? newline
                source
              end

              target_text = "".encode text.encoding
              sources.each { |source| target_text << source + newline }

              Option::COMPRESSOR_OPTION_COMBINATIONS.each do |compressor_options|
                Target.open ARCHIVE_PATH, compressor_options do |instance|
                  # Puts should ignore additional newlines and process arrays.
                  args = sources.map.with_index do |source, index|
                    if index.even?
                      source + newline
                    else
                      [source]
                    end
                  end

                  instance.puts(*args)
                end

                compressed_text = ::File.read ARCHIVE_PATH

                Option.get_compatible_decompressor_options(compressor_options) do |decompressor_options|
                  check_text target_text, compressed_text, decompressor_options
                end
              end
            end
          end
        end

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
            Option::COMPRESSOR_OPTION_COMBINATIONS.each do |compressor_options|
              Target.open(ARCHIVE_PATH, compressor_options) { |instance| instance.write text }

              compressed_text = ::File.read ARCHIVE_PATH

              Option.get_compatible_decompressor_options(compressor_options) do |decompressor_options|
                check_text text, compressed_text, decompressor_options
              end
            end
          end
        end

        def test_native_compress
          LARGE_TEXTS.each do |text|
            Target.open(ARCHIVE_PATH) { |instance| instance.write text }

            Common.native_decompress ARCHIVE_PATH, NATIVE_SOURCE_PATH

            decompressed_text = ::File.read NATIVE_SOURCE_PATH
            decompressed_text.force_encoding text.encoding
            assert_equal text, decompressed_text
          end
        end

        # -----

        protected def get_sources(text, portion_length)
          sources = text
            .chars
            .each_slice(portion_length)
            .map(&:join)

          return [""] if sources.empty?

          sources
        end

        protected def check_text(text, compressed_text, decompressor_options)
          decompressed_text = String.decompress compressed_text, decompressor_options
          decompressed_text.force_encoding text.encoding

          assert_equal text, decompressed_text
        end

        protected def target
          self.class::Target
        end
      end

      Minitest << WriterHelpers
    end
  end
end
