# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/decompressor"
require "lzws/string"

require_relative "../common"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"
require_relative "abstract_processor"

module LZWS
  module Test
    module Stream
      class Decompressor < AbstractProcessor
        Target = LZWS::Stream::Decompressor
        String = LZWS::String

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
              decompressor.read(invalid_string, &NOOP_PROC)
            end
          end

          assert_raises ValidateError do
            decompressor.read ""
          end

          decompressor.close(&NOOP_PROC)

          assert_raises UsedAfterCloseError do
            decompressor.read("", &NOOP_PROC)
          end
        end

        def test_texts
          Common::TEXTS.each do |text|
            Common::ENCODINGS.each do |encoding|
              encoded_text = text.dup.force_encoding encoding

              Common::PORTION_BYTESIZES.each do |portion_bytesize|
                Option::COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
                  compressed_text = String.compress encoded_text, compressor_options

                  decompressor = Target.new decompressor_options

                  source = ""
                  source.force_encoding Encoding::BINARY

                  decompressed_buffer = StringIO.new
                  decompressed_buffer.set_encoding Encoding::BINARY

                  writer = proc { |portion| decompressed_buffer << portion }

                  compressed_text_offset = 0

                  loop do
                    portion = compressed_text.byteslice compressed_text_offset, portion_bytesize
                    break if portion.nil?

                    compressed_text_offset += portion_bytesize
                    source << portion

                    bytes_read = decompressor.read(source, &writer)
                    source     = source.byteslice bytes_read, source.bytesize - bytes_read
                  end

                  decompressor.flush(&writer)

                  refute decompressor.closed?
                  decompressor.close(&writer)
                  assert decompressor.closed?

                  decompressed_text = decompressed_buffer.string
                  decompressed_text.force_encoding encoding

                  assert_equal encoded_text, decompressed_text
                end
              end
            end
          end
        end
      end

      Minitest << Decompressor
    end
  end
end
