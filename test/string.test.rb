# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/string"

require_relative "common"
require_relative "minitest"
require_relative "option"
require_relative "validation"

module LZWS
  module Test
    class String < Minitest::Unit::TestCase
      Target = LZWS::String

      def test_invalid_arguments
        Validation::INVALID_STRINGS.each do |invalid_string|
          assert_raises ValidateError do
            Target.compress invalid_string
          end

          assert_raises ValidateError do
            Target.decompress invalid_string
          end
        end

        Option::INVALID_COMPRESSOR_OPTIONS.each do |invalid_options|
          assert_raises ValidateError do
            Target.compress "", invalid_options
          end
        end

        Option::INVALID_DECOMPRESSOR_OPTIONS.each do |invalid_options|
          assert_raises ValidateError do
            Target.decompress "", invalid_options
          end
        end
      end

      def test_texts
        Common::TEXTS.each do |text|
          Option::COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
            compressed_text   = Target.compress text, compressor_options
            decompressed_text = Target.decompress compressed_text, decompressor_options

            assert_equal text, decompressed_text
          end
        end
      end
    end

    Minitest << String
  end
end
