# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws"

require_relative "minitest"

module LZWS
  module Test
    class Version < Minitest::Test
      def test_versions
        refute_nil LZWS::VERSION
        refute_nil LZWS::LIBRARY_VERSION
      end
    end

    Minitest << Version
  end
end
