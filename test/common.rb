# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "securerandom"

module LZWS
  module Test
    module Common
      BASE_PATH = File.expand_path File.join(File.dirname(__FILE__), "..").freeze
      TEMP_PATH = File.join(BASE_PATH, "tmp").freeze

      TEXTS = [
        "hello world".b,
        "tobeornottobeortobeornot".b,
        SecureRandom.random_bytes(1 << 15) # 32 kBytes
      ]
      .freeze
    end
  end
end
