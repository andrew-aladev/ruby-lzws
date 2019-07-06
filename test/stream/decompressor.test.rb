# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/decompressor"
require "lzws/string"

require_relative "../common"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Test
    module Stream
      class Decompressor < Minitest::Unit::TestCase
        Target = LZWS::Stream::Decompressor
        String = LZWS::String

        NOOP_PROC = Validation::NOOP_PROC

        def test_invalid_initialize
          Option::INVALID_DECOMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises ValidateError do
              Target.new invalid_options
            end
          end

          decompressor = Target.new

          Validation::INVALID_STRINGS.each do |invalid_string|
            assert_raises ValidateError do
              decompressor.read(invalid_string, &NOOP_PROC)
            end
          end

          assert_raises ValidateError do
            decompressor.read ""
          end

          assert_raises ValidateError do
            decompressor.flush
          end

          assert_raises ValidateError do
            decompressor.close
          end

          decompressor.close(&NOOP_PROC)

          assert_raises UsedAfterCloseError do
            decompressor.read("", &NOOP_PROC)
          end

          assert_raises UsedAfterCloseError do
            decompressor.flush(&NOOP_PROC)
          end
        end

        def test_texts
          Common::TEXTS.each do |text|
            Common::PORTION_LENGTHS.each do |portion_length|
              Option::COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
                compressed_text = String.compress text, compressor_options

                decompressed_buffer = StringIO.new
                decompressed_buffer.set_encoding Encoding::BINARY

                writer       = proc { |portion| decompressed_buffer << portion }
                decompressor = Target.new decompressor_options

                compressed_text_offset = 0
                source                 = "".b

                loop do
                  portion = compressed_text[compressed_text_offset...(compressed_text_offset + portion_length)]
                  break if portion.nil?

                  compressed_text_offset += portion_length
                  source << portion

                  read_length = decompressor.read(source, &writer)
                  source      = source[read_length..-1]
                end

                decompressor.flush(&writer)

                refute decompressor.closed?
                decompressor.close(&writer)
                assert decompressor.closed?

                decompressed_text = decompressed_buffer.string
                assert_equal text, decompressed_text
              end
            end
          end
        end
      end

      Minitest << Decompressor
    end
  end
end
