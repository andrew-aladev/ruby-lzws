# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/test/stream/raw/decompressor"
require "lzws/stream/raw/decompressor"
require "lzws/string"

require_relative "../../common"
require_relative "../../minitest"
require_relative "../../option"

module LZWS
  module Test
    module Stream
      module Raw
        class Decompressor < ADSP::Test::Stream::Raw::Decompressor
          Target = LZWS::Stream::Raw::Decompressor
          Option = Test::Option
          String = LZWS::String

          NATIVE_ARCHIVE_PATH = Common::NATIVE_ARCHIVE_PATH
          NATIVE_SOURCE_PATH  = Common::NATIVE_SOURCE_PATH

          def test_invalid_read
            super

            decompressor              = Target.new
            corrupted_compressed_text = "#{String.compress('1111')}1111".b

            assert_raises DecompressorCorruptedSourceError do
              decompressor.read corrupted_compressed_text, &NOOP_PROC
            end
          end

          def test_large_texts_and_native_compress
            options_generator = OCG.new(
              :text           => LARGE_TEXTS,
              :portion_length => LARGE_PORTION_LENGTHS
            )

            Common.parallel_options options_generator do |options, worker_index|
              text           = options[:text]
              portion_length = options[:portion_length]

              native_source_path  = Common.get_path NATIVE_SOURCE_PATH, worker_index
              native_archive_path = Common.get_path NATIVE_ARCHIVE_PATH, worker_index

              ::File.write native_source_path, text, :mode => "wb"
              Common.native_compress native_source_path, native_archive_path

              compressed_text = ::File.read native_archive_path, :mode => "rb"

              decompressed_buffer = ::StringIO.new
              decompressed_buffer.set_encoding ::Encoding::BINARY

              writer       = proc { |portion| decompressed_buffer << portion }
              decompressor = Target.new

              begin
                source                 = "".b
                compressed_text_offset = 0

                loop do
                  portion = compressed_text.byteslice compressed_text_offset, portion_length
                  break if portion.nil?

                  compressed_text_offset += portion_length
                  source << portion

                  bytes_read = decompressor.read source, &writer
                  source     = source.byteslice bytes_read, source.bytesize - bytes_read
                end
              ensure
                decompressor.close(&writer)
              end

              decompressed_text = decompressed_buffer.string
              decompressed_text.force_encoding text.encoding

              assert_equal text, decompressed_text
            end
          end
        end

        Minitest << Decompressor
      end
    end
  end
end
