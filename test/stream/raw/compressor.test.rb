# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/raw/compressor"
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
        class Compressor < Abstract
          Target = LZWS::Stream::Raw::Compressor
          String = LZWS::String

          ARCHIVE_PATH       = Common::ARCHIVE_PATH
          NATIVE_SOURCE_PATH = Common::NATIVE_SOURCE_PATH
          TEXTS              = Common::TEXTS
          PORTION_LENGTHS    = Common::PORTION_LENGTHS

          COMPATIBLE_OPTION_COMBINATIONS = Option::COMPATIBLE_OPTION_COMBINATIONS

          def test_invalid_initialize
            Option::INVALID_COMPRESSOR_OPTIONS.each do |invalid_options|
              assert_raises ValidateError do
                Target.new invalid_options
              end
            end
          end

          def test_invalid_write
            compressor = Target.new

            Validation::INVALID_STRINGS.each do |invalid_string|
              assert_raises ValidateError do
                compressor.write invalid_string, &NOOP_PROC
              end
            end

            assert_raises ValidateError do
              compressor.write ""
            end

            compressor.close(&NOOP_PROC)

            assert_raises UsedAfterCloseError do
              compressor.write "", &NOOP_PROC
            end
          end

          def test_texts
            TEXTS.each do |text|
              PORTION_LENGTHS.each do |portion_length|
                COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
                  compressor = Target.new compressor_options

                  begin
                    compressed_buffer = ::StringIO.new
                    compressed_buffer.set_encoding ::Encoding::BINARY

                    writer = proc { |portion| compressed_buffer << portion }

                    source      = "".b
                    text_offset = 0

                    loop do
                      portion = text.byteslice text_offset, portion_length
                      break if portion.nil?

                      text_offset += portion_length
                      source << portion

                      bytes_written = compressor.write source, &writer
                      source        = source.byteslice bytes_written, source.bytesize - bytes_written
                    end

                    compressor.flush(&writer)
                  ensure
                    refute compressor.closed?
                    compressor.close(&writer)
                    assert compressor.closed?
                  end

                  compressed_text = compressed_buffer.string

                  decompressed_text = String.decompress compressed_text, decompressor_options
                  decompressed_text.force_encoding text.encoding

                  assert_equal text, decompressed_text
                end
              end
            end
          end

          def test_native_compress
            # Default options should be compatible with native util.

            TEXTS.each do |text|
              compressor = Target.new

              ::File.open(ARCHIVE_PATH, "wb") do |archive|
                writer = proc { |portion| archive << portion }
                source = text.dup

                loop do
                  bytes_written = compressor.write source, &writer
                  source        = source.byteslice bytes_written, source.bytesize - bytes_written

                  break if source.empty?
                end
              ensure
                compressor.close(&writer)
              end

              Common.native_decompress ARCHIVE_PATH, NATIVE_SOURCE_PATH

              decompressed_text = ::File.read NATIVE_SOURCE_PATH
              decompressed_text.force_encoding text.encoding

              assert_equal text, decompressed_text
            end
          end
        end

        Minitest << Compressor
      end
    end
  end
end
