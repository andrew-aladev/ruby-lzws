# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

module LZWS
  module Test
    module Validation
      NOOP_PROC = proc {}
      ALL_BASE_TYPES = [
        nil,
        1,
        1.1,
        "1",
        true,
        "a",
        :a,
        {},
        [],
        STDOUT,
        NOOP_PROC
      ]
      .freeze

      INVALID_INTEGERS = (ALL_BASE_TYPES - [1]).freeze
      INVALID_BOOLS    = (ALL_BASE_TYPES - [true]).freeze
      INVALID_STRINGS  = (ALL_BASE_TYPES - %w[1 a]).freeze
      INVALID_HASHES   = (ALL_BASE_TYPES - [{}]).freeze
      INVALID_IOS      = (ALL_BASE_TYPES - [STDOUT]).freeze
      INVALID_PROCS    = (ALL_BASE_TYPES - [NOOP_PROC]).freeze
    end
  end
end
