# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/string"
require "lzws_ext"

require_relative "option"

module LZWS
  # LZWS::String class.
  class String < ADSP::String
    # Current option class.
    Option = LZWS::Option

    def self.native_compress_string(*args)
      LZWS._native_compress_string(*args)
    end

    def self.native_decompress_string(*args)
      LZWS._native_decompress_string(*args)
    end
  end
end
