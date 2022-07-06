# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/test/stream/writer_helpers"
require "lzws/stream/writer"
require "lzws/string"

require_relative "../common"
require_relative "../minitest"
require_relative "../option"

module LZWS
  module Test
    module Stream
      class WriterHelpers < ADSP::Test::Stream::WriterHelpers
        Target = LZWS::Stream::Writer
        Option = Test::Option
        String = LZWS::String

        NATIVE_SOURCE_PATH = Common::NATIVE_SOURCE_PATH

        def test_open_with_large_texts_and_native_compress
          options_generator = OCG.new(
            :text           => LARGE_TEXTS,
            :portion_length => LARGE_PORTION_LENGTHS
          )

          Common.parallel_options options_generator do |options, worker_index|
            text           = options[:text]
            portion_length = options[:portion_length]

            native_source_path = Common.get_path NATIVE_SOURCE_PATH, worker_index
            archive_path       = Common.get_path ARCHIVE_PATH, worker_index

            sources = get_sources text, portion_length

            Target.open archive_path do |instance|
              sources.each { |source| instance.write source }
            end

            Common.native_decompress archive_path, native_source_path

            decompressed_text = ::File.read native_source_path, :mode => "rb"
            decompressed_text.force_encoding text.encoding

            assert_equal text, decompressed_text
          end
        end
      end

      Minitest << WriterHelpers
    end
  end
end
