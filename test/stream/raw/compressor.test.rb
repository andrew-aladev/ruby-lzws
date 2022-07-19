# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "adsp/test/stream/raw/compressor"
require "lzws/stream/raw/compressor"
require "lzws/string"

require_relative "../../common"
require_relative "../../minitest"
require_relative "../../option"

module LZWS
  module Test
    module Stream
      module Raw
        class Compressor < ADSP::Test::Stream::Raw::Compressor
          Target = LZWS::Stream::Raw::Compressor
          Option = Test::Option
          String = LZWS::String

          ARCHIVE_PATH       = Common::ARCHIVE_PATH
          NATIVE_SOURCE_PATH = Common::NATIVE_SOURCE_PATH

          def test_large_texts_and_native_compress
            options_generator = OCG.new(
              :text           => LARGE_TEXTS,
              :portion_length => LARGE_PORTION_LENGTHS
            )

            Common.parallel_options options_generator do |options, worker_index|
              text           = options[:text]
              portion_length = options[:portion_length]

              archive_path       = Common.get_path ARCHIVE_PATH, worker_index
              native_source_path = Common.get_path NATIVE_SOURCE_PATH, worker_index

              compressor = Target.new

              ::File.open archive_path, "wb" do |archive|
                writer = proc { |portion| archive << portion }

                begin
                  source      = "".b
                  text_offset = 0

                  loop do
                    portion = text.byteslice text_offset, portion_length
                    break if portion.nil?

                    text_offset += portion_length
                    source << portion

                    bytes_written = compressor.write source, &writer
                    source        = source.byteslice bytes_written, source.bytesize - bytes_written
                  end
                ensure
                  compressor.close(&writer)
                end
              end

              Common.native_decompress archive_path, native_source_path

              decompressed_text = ::File.read native_source_path, :mode => "rb"
              decompressed_text.force_encoding text.encoding

              assert_equal text, decompressed_text
            end
          end
        end

        Minitest << Compressor
      end
    end
  end
end
