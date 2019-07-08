# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "securerandom"

module LZWS
  module Test
    module Common
      BASE_PATH = ::File.expand_path ::File.join(::File.dirname(__FILE__), "..").freeze
      TEMP_PATH = ::File.join(BASE_PATH, "tmp").freeze

      TEXTS = [
        "",
        "hello world",
        "tobeornottobeortobeornot",
        SecureRandom.random_bytes(1 << 13) # 8 KB
      ]
      .freeze

      PORTION_BYTESIZES = [
        1,
        2,
        512
      ]
      .freeze

      ENCODINGS = %w[
        binary
        UTF-8
        UTF-16
      ]
      .map { |encoding_name| Encoding.find encoding_name }
      .freeze
    end
  end
end
