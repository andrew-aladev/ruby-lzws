# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/writer"
require "lzws/string"

require_relative "abstract"
require_relative "../common"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Test
    module Stream
      class Writer < Abstract
        Target = LZWS::Stream::Writer
        String = LZWS::String

        ARCHIVE_PATH    = Common::ARCHIVE_PATH
        TEXTS           = Common::TEXTS
        PORTION_LENGTHS = Common::PORTION_LENGTHS

        COMPATIBLE_OPTION_COMBINATIONS = Option::COMPATIBLE_OPTION_COMBINATIONS

        def test_invalid_initialize
          Option::INVALID_COMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises ValidateError do
              target.new STDOUT, invalid_options
            end
          end

          super
        end

        # -- synchronous --

        def test_texts
          TEXTS.each do |text|
            PORTION_LENGTHS.each do |portion_length|
              sources = text
                .chars
                .each_slice(portion_length)
                .map(&:join)

              COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
                ::File.open ARCHIVE_PATH, "wb" do |file|
                  instance = target.new file, compressor_options

                  begin
                    instance.write(*sources)
                    instance.flush
                  ensure
                    refute instance.closed?
                    instance.close
                    assert instance.closed?
                  end
                end

                check_archive text, decompressor_options
              end
            end
          end
        end

        # -- asynchronous --

        def test_texts_nonblock
        end

        # -- helpers --

        def test_print
          TEXTS.each do |text|
            COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
              ::File.open ARCHIVE_PATH, "wb" do |file|
                instance = target.new file, compressor_options

                $LAST_READ_LINE = text

                begin
                  instance.print
                ensure
                  instance.close
                  $LAST_READ_LINE = nil
                end
              end

              check_archive text, decompressor_options
            end

            # This part of test is for not empty texts only.
            next if text.empty?

            PORTION_LENGTHS.each do |portion_length|
              field_separator  = " ".encode text.encoding
              record_separator = "\n".encode text.encoding

              sources = text
                .chars
                .each_slice(portion_length)
                .map(&:join)

              target_text = "".encode text.encoding
              sources.each { |source| target_text << source + field_separator }
              target_text << record_separator

              COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
                ::File.open ARCHIVE_PATH, "wb" do |file|
                  instance = target.new file, compressor_options

                  $OUTPUT_FIELD_SEPARATOR  = field_separator
                  $OUTPUT_RECORD_SEPARATOR = record_separator

                  begin
                    instance.print(*sources)
                  ensure
                    instance.close
                    $OUTPUT_FIELD_SEPARATOR  = nil
                    $OUTPUT_RECORD_SEPARATOR = nil
                  end
                end

                check_archive target_text, decompressor_options
              end
            end
          end
        end

        def test_printf
          TEXTS.each do |text|
            PORTION_LENGTHS.each do |portion_length|
              sources = text
                .chars
                .each_slice(portion_length)
                .map(&:join)

              COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
                ::File.open ARCHIVE_PATH, "wb" do |file|
                  instance = target.new file, compressor_options

                  begin
                    sources.each { |source| instance.printf "%s", source }
                  ensure
                    instance.close
                  end
                end

                check_archive text, decompressor_options
              end
            end
          end
        end

        def test_invalid_putc
          instance = target.new STDOUT

          Validation::INVALID_CHARS.each do |invalid_char|
            assert_raises ValidateError do
              instance.putc invalid_char
            end
          end
        end

        def test_putc
          TEXTS.each do |text|
            COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
              ::File.open ARCHIVE_PATH, "wb" do |file|
                instance = target.new file, compressor_options

                begin
                  # Putc should process numbers and strings.
                  text.chars.map.with_index do |char, index|
                    if index.even?
                      instance.putc char.ord, :encoding => text.encoding
                    else
                      instance.putc char
                    end
                  end
                ensure
                  instance.close
                end
              end

              check_archive text, decompressor_options
            end
          end
        end

        def test_puts
          TEXTS.each do |text|
            PORTION_LENGTHS.each do |portion_length|
              newline = "\n".encode text.encoding

              sources = text
                .chars
                .each_slice(portion_length)
                .map(&:join)
                .map do |source|
                  source.delete_suffix! newline while source.end_with? newline
                  source
                end

              target_text = "".encode text.encoding
              sources.each { |source| target_text << source + newline }

              COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
                ::File.open ARCHIVE_PATH, "wb" do |file|
                  instance = target.new file, compressor_options

                  begin
                    # Puts should ignore additional newlines and process arrays.
                    args = sources.map.with_index do |source, index|
                      if index.even?
                        source + newline
                      else
                        [source]
                      end
                    end

                    instance.puts(*args)
                  ensure
                    instance.close
                  end
                end

                check_archive target_text, decompressor_options
              end
            end
          end
        end

        # -----

        protected def check_archive(text, decompressor_options)
          compressed_text = ::File.read ARCHIVE_PATH

          decompressed_text = String.decompress compressed_text, decompressor_options
          decompressed_text.force_encoding text.encoding

          assert_equal text, decompressed_text
        end
      end

      Minitest << Writer
    end
  end
end
