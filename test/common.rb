# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

module LZWS
  module Test
    module Common
      BASE_PATH = File.expand_path File.join(File.dirname(__FILE__), "..").freeze
      TEMP_PATH = File.join(BASE_PATH, "tmp").freeze

      TEXTS = [
        "hello world",
        "tobeornottobeortobeornot",
        "qqqqqqqqqqqqqqqqqqqqqqqq",
        "qqqqqqqqqqqqqqqqqqqqqqqz"
      ]
      .freeze
    end
  end
end
