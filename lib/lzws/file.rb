# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/file"
require "lzws_ext"

require_relative "option"

module LZWS
  # LZWS::File class.
  class File < ADSP::File
    # Current option class.
    Option = LZWS::Option

    def self.native_compress_io(*args)
      LZWS._native_compress_io(*args)
    end

    def self.native_decompress_io(*args)
      LZWS._native_decompress_io(*args)
    end
  end
end
