# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "abstract"
require_relative "../processor/compressor"
require_relative "../../validation"

module LZWS
  module Stream
    module IO
      class Writer < Abstract
        def initialize(destination_io, options = {}, *args)
          compressor = Processor::Compressor.new options

          super compressor, destination_io, *args
        end

        def write(*objects)
          total_bytes_written = 0

          bytes_written        = write_data @buffer.string
          total_bytes_written += bytes_written

          objects.each do |object|
            bytes_written        = write_data object.to_s
            @pos                += bytes_written
            total_bytes_written += bytes_written
          end

          total_bytes_written
        end

        protected def write_data(source)
          source = prepare_source_for_write source
          @processor.write(source) { |portion| @io.write portion }
        end

        def write_nonblock(object, *options)
          total_bytes_written = 0
        end

        protected def prepare_source_for_write(source)
          if @external_encoding.nil?
            source
          else
            source.encode @external_encoding
          end
        end
      end
    end
  end
end
