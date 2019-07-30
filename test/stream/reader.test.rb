# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "abstract"
require_relative "../common"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

require "lzws/stream/reader"
require "lzws/string"
require "socket"

module LZWS
  module Test
    module Stream
      class Reader < Abstract
        Target = LZWS::Stream::Reader
        String = LZWS::String

        ARCHIVE_PATH     = Common::ARCHIVE_PATH
        UNIX_SOCKET_PATH = Common::UNIX_SOCKET_PATH
        ENCODINGS        = Common::ENCODINGS
        TEXTS            = Common::TEXTS
        PORTION_LENGTHS  = Common::PORTION_LENGTHS

        COMPATIBLE_OPTION_COMBINATIONS = Option::COMPATIBLE_OPTION_COMBINATIONS

        def test_invalid_initialize
          Option::INVALID_DECOMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises ValidateError do
              target.new ::STDIN, invalid_options
            end
          end

          (Validation::INVALID_POSITIVE_INTEGERS - [nil]).each do |invalid_integer|
            assert_raises ValidateError do
              target.new ::STDIN, :io_chunk_size => invalid_integer
            end
          end

          super
        end

        # -- synchronous --

        def test_invalid_read
          instance = target.new ::STDIN

          (Validation::INVALID_NOT_NEGATIVE_INTEGERS - [nil]).each do |invalid_integer|
            assert_raises ValidateError do
              instance.read invalid_integer
            end
          end

          (Validation::INVALID_STRINGS - [nil]).each do |invalid_string|
            assert_raises ValidateError do
              instance.read nil, invalid_string
            end
          end
        end

        # -- asynchronous --

        # -----
      end

      Minitest << Reader
    end
  end
end
