# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "minitest"

module LZWS
  class StringTest < Minitest::Unit::TestCase
  end

  Minitest << StringTest
end
