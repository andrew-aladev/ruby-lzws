# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/raw/decompressor"
require "lzws/string"

require_relative "abstract"
require_relative "../../common"
require_relative "../../minitest"
require_relative "../../option"
require_relative "../../validation"

module LZWS
  module Test
    module Stream
      module Raw
        class Decompressor < Abstract
          Target = LZWS::Stream::Raw::Decompressor
          String = LZWS::String

          NATIVE_SOURCE_PATH  = Common::NATIVE_SOURCE_PATH
          NATIVE_ARCHIVE_PATH = Common::NATIVE_ARCHIVE_PATH
          TEXTS               = Common::TEXTS
          PORTION_LENGTHS     = Common::PORTION_LENGTHS

          COMPATIBLE_OPTION_COMBINATIONS = Option::COMPATIBLE_OPTION_COMBINATIONS

          def test_invalid_initialize
            Option::INVALID_DECOMPRESSOR_OPTIONS.each do |invalid_options|
              assert_raises ValidateError do
                Target.new invalid_options
              end
            end
          end

          def test_invalid_read
            decompressor = Target.new

            Validation::INVALID_STRINGS.each do |invalid_string|
              assert_raises ValidateError do
                decompressor.read invalid_string, &NOOP_PROC
              end
            end

            assert_raises ValidateError do
              decompressor.read ""
            end

            decompressor.close(&NOOP_PROC)

            assert_raises UsedAfterCloseError do
              decompressor.read "", &NOOP_PROC
            end
          end

          def test_texts
            TEXTS.each do |text|
              PORTION_LENGTHS.each do |portion_length|
                COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
                  compressed_text = String.compress text, compressor_options

                  decompressor = Target.new decompressor_options

                  begin
                    decompressed_buffer = StringIO.new
                    decompressed_buffer.set_encoding Encoding::BINARY

                    writer = proc { |portion| decompressed_buffer << portion }

                    source                 = "".b
                    compressed_text_offset = 0

                    loop do
                      portion = compressed_text.byteslice compressed_text_offset, portion_length
                      break if portion.nil?

                      compressed_text_offset += portion_length
                      source << portion

                      bytes_read = decompressor.read source, &writer
                      source     = source.byteslice bytes_read, source.bytesize - bytes_read
                    end

                    decompressor.flush(&writer)
                  ensure
                    refute decompressor.closed?
                    decompressor.close(&writer)
                    assert decompressor.closed?
                  end

                  decompressed_text = decompressed_buffer.string
                  decompressed_text.force_encoding text.encoding

                  assert_equal text, decompressed_text
                end
              end
            end
          end

          def test_native_decompress
            # Default options should be compatible with native util.

            TEXTS.each do |text|
              ::File.write NATIVE_SOURCE_PATH, text
              Common.native_compress NATIVE_SOURCE_PATH, NATIVE_ARCHIVE_PATH

              decompressor = Target.new

              begin
                decompressed_buffer = StringIO.new
                decompressed_buffer.set_encoding Encoding::BINARY

                writer = proc { |portion| decompressed_buffer << portion }

                source = ::File.read NATIVE_ARCHIVE_PATH

                loop do
                  bytes_read = decompressor.read source, &writer
                  source     = source.byteslice bytes_read, source.bytesize - bytes_read

                  break if source.empty?
                end
              ensure
                decompressor.close(&writer)
              end

              decompressed_text = decompressed_buffer.string
              decompressed_text.force_encoding text.encoding

              assert_equal text, decompressed_text
            end
          end
        end

        Minitest << Decompressor
      end
    end
  end
end
