# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/writer"

require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Test
    module Stream
      class Writer < Minitest::Unit::TestCase
        Target = LZWS::Stream::Writer

        def test_invalid_initialize
          Validation::INVALID_IOS.each do |invalid_io|
            assert_raises ValidateError do
              Target.new invalid_io
            end
          end

          Option::INVALID_COMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises ValidateError do
              Target.new STDOUT, invalid_options
            end
          end
        end
      end

      Minitest << Writer
    end
  end
end
