# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/stream/writer"
require "lzws/string"

require_relative "abstract"
require_relative "../common"
require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Test
    module Stream
      class Writer < Abstract
        Target = LZWS::Stream::Writer
        String = LZWS::String

        ARCHIVE_PATH      = Common::ARCHIVE_PATH
        TEXTS             = Common::TEXTS
        PORTION_BYTESIZES = Common::PORTION_BYTESIZES

        COMPATIBLE_OPTION_COMBINATIONS = Option::COMPATIBLE_OPTION_COMBINATIONS

        def test_invalid_initialize
          Option::INVALID_COMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises ValidateError do
              target.new STDOUT, invalid_options
            end
          end

          super
        end

        def test_puts
          TEXTS.each do |text|
            PORTION_BYTESIZES.each do |portion_bytesize|
              newline = "\n".encode text.encoding

              sources = text
                .bytes
                .each_slice(portion_bytesize)
                .map(&:join)
                .map do |source|
                  source.encode! text.encoding
                  source.delete_suffix! newline if source.end_with? newline
                  source
                end

              target_text = "".encode text.encoding
              sources.each { |source| target_text << source + newline }

              COMPATIBLE_OPTION_COMBINATIONS.each do |compressor_options, decompressor_options|
                ::File.open ARCHIVE_PATH, "wb" do |file|
                  instance = target.new file, compressor_options

                  # Puts should ignore additional newlines and process arrays.
                  args = sources.map.with_index do |source, index|
                    if index.even?
                      source + newline
                    else
                      [source]
                    end
                  end

                  instance.puts(*args)
                  instance.close

                  compressed_text = ::File.read ARCHIVE_PATH

                  decompressed_text = String.decompress compressed_text, decompressor_options
                  decompressed_text.force_encoding text.encoding

                  assert_equal target_text, decompressed_text
                end
              end
            end
          end
        end
      end

      Minitest << Writer
    end
  end
end
