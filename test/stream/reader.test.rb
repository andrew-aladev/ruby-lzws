# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/test/stream/reader"
require "lzws/stream/reader"
require "lzws/string"
require "stringio"

require_relative "../minitest"
require_relative "../option"

module LZWS
  module Test
    module Stream
      class Reader < ADSP::Test::Stream::Reader
        Target = LZWS::Stream::Reader
        Option = Test::Option
        String = LZWS::String

        def test_invalid_read
          corrupted_compressed_text = "#{String.compress('1111')}1111".b
          instance                  = target.new ::StringIO.new(corrupted_compressed_text)

          assert_raises DecompressorCorruptedSourceError do
            instance.read
          end
        end

        def test_invalid_readpartial_and_read_nonblock
          super

          corrupted_compressed_text = "#{String.compress('1111')}1111".b
          instance                  = target.new ::StringIO.new(corrupted_compressed_text)

          assert_raises DecompressorCorruptedSourceError do
            instance.readpartial 1
          end

          instance = target.new ::StringIO.new(corrupted_compressed_text)

          assert_raises DecompressorCorruptedSourceError do
            instance.read_nonblock 1
          end
        end
      end

      Minitest << Reader
    end
  end
end
