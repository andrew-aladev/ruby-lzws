# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "securerandom"

module LZWS
  module Test
    module Common
      BASE_PATH = File.expand_path File.join(File.dirname(__FILE__), "..").freeze
      TEMP_PATH = File.join(BASE_PATH, "tmp").freeze

      TEXTS = [
        "".b,
        "hello world".b,
        "tobeornottobeortobeornot".b,
        SecureRandom.random_bytes(1 << 13) # 8 KB
      ]
      .freeze

      TEXT_PORTION_LENGTHS = [
        1,
        2,
        1 << 9 # 512 B
      ]
      .freeze
    end
  end
end
