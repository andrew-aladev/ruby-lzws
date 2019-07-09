# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/compressor"
require "lzws/string"

require_relative "../common"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"
require_relative "abstract_processor"

module LZWS
  module Test
    module Stream
      class Compressor < AbstractProcessor
        Target = LZWS::Stream::Compressor
        String = LZWS::String

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
              compressor.write(invalid_string, &NOOP_PROC)
            end
          end

          assert_raises ValidateError do
            compressor.write ""
          end

          compressor.close(&NOOP_PROC)

          assert_raises UsedAfterCloseError do
            compressor.write("", &NOOP_PROC)
          end
        end

        def test_texts
          Common::TEXTS.each do |text|
            Common::ENCODINGS.each do |encoding|
              encoded_text = text.dup.force_encoding encoding

              Common::PORTION_BYTESIZES.each do |portion_bytesize|
                Option::COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
                  compressor = Target.new compressor_options

                  source = ""
                  source.force_encoding encoding

                  compressed_buffer = StringIO.new
                  compressed_buffer.set_encoding Encoding::BINARY

                  writer = proc { |portion| compressed_buffer << portion }

                  encoded_text_offset = 0

                  loop do
                    portion = encoded_text.byteslice encoded_text_offset, portion_bytesize
                    break if portion.nil?

                    encoded_text_offset += portion_bytesize
                    source << portion

                    write_bytesize = compressor.write(source, &writer)
                    source         = source.byteslice write_bytesize, source.bytesize - write_bytesize
                  end

                  compressor.flush(&writer)

                  refute compressor.closed?
                  compressor.close(&writer)
                  assert compressor.closed?

                  compressed_text   = compressed_buffer.string
                  decompressed_text = String.decompress compressed_text, decompressor_options

                  decompressed_text.force_encoding encoding

                  assert_equal encoded_text, decompressed_text
                end
              end
            end
          end
        end
      end

      Minitest << Compressor
    end
  end
end
