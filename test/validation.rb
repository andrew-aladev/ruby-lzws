# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

module LZWS
  module Test
    module Validation
      ALL_BASE_TYPES = [nil, 1, 1.1, "1", true, "a", :a, {}, []].freeze

      INVALID_INTEGERS = (ALL_BASE_TYPES - [1]).freeze
      INVALID_BOOLS    = (ALL_BASE_TYPES - [true]).freeze
      INVALID_STRINGS  = (ALL_BASE_TYPES - %w[1 a]).freeze
      INVALID_HASHES   = (ALL_BASE_TYPES - [{}]).freeze
      INVALID_IOS      = ALL_BASE_TYPES
    end
  end
end
