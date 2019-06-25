# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/io"

require_relative "common"
require_relative "minitest"
require_relative "option"
require_relative "validation"

module LZWS
  module Test
    class IO < Minitest::Unit::TestCase
      Target = LZWS::IO

      ENCODING = "#{Encoding::BINARY}:#{Encoding::BINARY}".freeze

      def test_invalid_arguments
        ::IO.pipe do |read_io, write_io|
          Validation::INVALID_IOS.each do |invalid_io|
            assert_raises UnexpectedArgumentError do
              Target.compress invalid_io, write_io
            end

            assert_raises UnexpectedArgumentError do
              Target.compress read_io, invalid_io
            end

            assert_raises UnexpectedArgumentError do
              Target.decompress invalid_io, write_io
            end

            assert_raises UnexpectedArgumentError do
              Target.decompress read_io, invalid_io
            end
          end

          Option::INVALID_COMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises UnexpectedArgumentError do
              Target.compress read_io, write_io, invalid_options
            end
          end

          Option::INVALID_DECOMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises UnexpectedArgumentError do
              Target.decompress read_io, write_io, invalid_options
            end
          end
        end
      end

      def test_texts
        Common::TEXTS.each do |text|
          Option::COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
            ::IO.pipe(ENCODING) do |source_read_io, source_write_io|
              source_write_io << text
              source_write_io.close

              ::IO.pipe(ENCODING) do |compressed_read_io, compressed_write_io|
                Target.compress source_read_io, compressed_write_io, compressor_options
                compressed_write_io.close

                ::IO.pipe(ENCODING) do |decompressed_read_io, decompressed_write_io|
                  Target.decompress compressed_read_io, decompressed_write_io, decompressor_options
                  decompressed_write_io.close

                  decompressed_text = decompressed_read_io.read
                  assert_equal text, decompressed_text
                end
              end
            end
          end
        end
      end
    end

    Minitest << IO
  end
end
