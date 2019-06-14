# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/string"

require_relative "minitest"

module LZWS
  class StringTest < Minitest::Unit::TestCase
    INVALID_SOURCES = [1, nil, [], {}].freeze

    def test_invalid_arguments
      INVALID_SOURCES.each do |invalid_source|
        assert_raises UnexpectedArgumentError do
          String.compress invalid_source
        end

        assert_raises UnexpectedArgumentError do
          String.decompress invalid_source
        end
      end
    end
  end

  Minitest << StringTest
end
