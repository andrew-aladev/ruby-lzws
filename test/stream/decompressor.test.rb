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
          Validation::INVALID_PROCS.each do |invalid_proc|
            assert_raises ValidateError do
              Target.new invalid_proc
            end
          end

          Option::INVALID_DECOMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises ValidateError do
              Target.new NOOP_PROC, invalid_options
            end
          end

          decompressor = Target.new NOOP_PROC
          decompressor.close

          assert_raises UsedAfterCloseError do
            decompressor.read ""
          end

          assert_raises UsedAfterCloseError do
            decompressor.flush
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
                decompressor = Target.new writer, decompressor_options

                compressed_text_offset = 0
                source                 = "".b

                loop do
                  portion = compressed_text[compressed_text_offset...(compressed_text_offset + portion_length)]
                  break if portion.nil?

                  compressed_text_offset += portion_length
                  source << portion

                  read_length = decompressor.read source
                  source      = source[read_length..-1]
                end

                decompressor.flush
                decompressor.close

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
