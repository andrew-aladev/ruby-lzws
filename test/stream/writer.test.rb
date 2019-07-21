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

                # Putc should process numbers and strings.
                text.chars.map.with_index do |char, index|
                  if index.even?
                    instance.putc char.ord, :encoding => text.encoding
                  else
                    instance.putc char
                  end
                end

                instance.close

                compressed_text = ::File.read ARCHIVE_PATH

                decompressed_text = String.decompress compressed_text, decompressor_options
                decompressed_text.force_encoding text.encoding

                assert_equal text, decompressed_text
              end
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
                  source.delete_suffix! newline if source.end_with? newline
                  source
                end

              target_text = "".encode text.encoding
              sources.each { |source| target_text << source + newline }

              COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
                ::File.open ARCHIVE_PATH, "wb" do |file|
                  instance = target.new file, compressor_options

                  # Puts should ignore additional newlines and process arrays.
                  args = sources.map.with_index do |source, index|
                    if index.even?
                      source + newline
                    else
                      [source]
                    end
                  end

                  instance.puts(*args)
                  instance.close

                  compressed_text = ::File.read ARCHIVE_PATH

                  decompressed_text = String.decompress compressed_text, decompressor_options
                  decompressed_text.force_encoding text.encoding

                  assert_equal target_text, decompressed_text
                end
              end
            end
          end
        end
      end

      Minitest << Writer
    end
  end
end
