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
              Target.new invalid_proc, NOOP_PROC
            end

            assert_raises ValidateError do
              Target.new NOOP_PROC, invalid_proc
            end
          end

          Option::INVALID_DECOMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises ValidateError do
              Target.new NOOP_PROC, NOOP_PROC, invalid_options
            end
          end

          invalid_reader     = proc { nil }
          invalid_compressor = Target.new invalid_reader, NOOP_PROC

          assert_raises NotEnoughSourceError do
            invalid_compressor.read_magic_header
          end

          assert_raises NotEnoughSourceError do
            invalid_compressor.read
          end
        end

        def test_texts
          Common::TEXTS.each do |text|
            Common::TEXT_PORTION_LENGTHS.each do |text_portion_length|
              Option::COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
                compressed_text = String.compress text, compressor_options

                portion_offset = 0

                reader = proc do
                  next nil if !portion_offset == 0 && portion_offset >= compressed_text.length

                  next_portion_offset = portion_offset + text_portion_length
                  portion             = compressed_text[portion_offset...next_portion_offset]
                  portion_offset      = next_portion_offset

                  portion
                end

                decompressed_buffer = StringIO.new
                decompressed_buffer.set_encoding Encoding::BINARY

                writer = proc { |portion| decompressed_buffer << portion }

                decompressor = Target.new reader, writer, decompressor_options
                decompressor.read_magic_header unless compressor_options[:without_magic_header]
                decompressor.read

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
