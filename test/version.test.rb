# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/test/version"
require "lzws"

require_relative "minitest"

module LZWS
  module Test
    class Version < ADSP::Test::Version
      def test_version
        refute_nil LZWS::VERSION
        refute_nil LZWS::LIBRARY_VERSION
      end
    end

    Minitest << Version
  end
end
