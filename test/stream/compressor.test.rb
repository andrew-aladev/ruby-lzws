# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/compressor"
require "lzws/string"

require_relative "../common"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Test
    module Stream
      class Compressor < Minitest::Unit::TestCase
        Target = LZWS::Stream::Compressor
        String = LZWS::String

        NOOP_PROC = Validation::NOOP_PROC

        def test_invalid_initialize
          Validation::INVALID_PROCS.each do |invalid_proc|
            assert_raises ValidateError do
              Target.new invalid_proc
            end
          end

          Option::INVALID_COMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises ValidateError do
              Target.new NOOP_PROC, invalid_options
            end
          end

          compressor = Target.new NOOP_PROC
          compressor.close

          assert_raises UsedAfterCloseError do
            compressor.write ""
          end

          assert_raises UsedAfterCloseError do
            compressor.flush
          end
        end

        def test_texts
          Common::TEXTS.each do |text|
            Common::PORTION_LENGTHS.each do |portion_length|
              Option::COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
                compressed_buffer = StringIO.new
                compressed_buffer.set_encoding Encoding::BINARY

                writer     = proc { |portion| compressed_buffer << portion }
                compressor = Target.new writer, compressor_options

                text_offset = 0
                source      = "".b

                loop do
                  portion = text[text_offset...(text_offset + portion_length)]
                  break if portion.nil?

                  text_offset += portion_length
                  source << portion

                  write_length = compressor.write source
                  source       = source[write_length..-1]
                end

                compressor.flush

                refute compressor.closed?
                compressor.close
                assert compressor.closed?

                compressed_text   = compressed_buffer.string
                decompressed_text = String.decompress compressed_text, decompressor_options

                assert_equal text, decompressed_text
              end
            end
          end
        end
      end

      Minitest << Compressor
    end
  end
end
