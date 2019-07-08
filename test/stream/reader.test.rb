# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/reader"

require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Test
    module Stream
      class Reader < Minitest::Unit::TestCase
        Target = LZWS::Stream::Reader

        def test_invalid_initialize
          Validation::INVALID_IOS.each do |invalid_io|
            assert_raises ValidateError do
              Target.new invalid_io
            end
          end

          Option::INVALID_DECOMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises ValidateError do
              Target.new STDOUT, invalid_options
            end
          end
        end
      end

      Minitest << Reader
    end
  end
end
