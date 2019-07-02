# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

module LZWS
  module Test
    module Validation
      NOOP_PROC = proc {}

      TYPES = [
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

      INVALID_INTEGERS = (TYPES - [1]).freeze
      INVALID_BOOLS    = (TYPES - [true]).freeze
      INVALID_STRINGS  = (TYPES - %w[1 a]).freeze
      INVALID_HASHES   = (TYPES - [{}]).freeze
      INVALID_IOS      = (TYPES - [STDOUT]).freeze
      INVALID_PROCS    = (TYPES - [NOOP_PROC]).freeze

      INVALID_POSITIVE_INTEGERS = (INVALID_INTEGERS + [-1]).freeze
    end
  end
end
