# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/decompressor"

require_relative "../common"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Test
    module Stream
      class Decompressor < Minitest::Unit::TestCase
        Target = LZWS::Stream::Decompressor

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
        end

        def test_texts
          Common::TEXTS.each do |text|
            Option::COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
              Target.new NOOP_PROC, NOOP_PROC, decompressor_options
            end
          end
        end
      end

      Minitest << Decompressor
    end
  end
end
