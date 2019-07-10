# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "abstract"
require_relative "../compressor"
require_relative "../../validation"

module LZWS
  module Stream
    module IO
      class Writer < Abstract
        def initialize(destination_io, options = {}, *args)
          compressor = Compressor.new options

          super compressor, destination_io, *args
        end

        def write(*objects)
          if @buffer.bytesize > 0
            # Write remaining buffer.
            @io.write @buffer
            reset_buffer
          end

          total_bytes_written = 0

          objects.each do |object|
            source = prepare_source_for_write object.to_s

            # Stream will write all data without any remainder.
            bytes_written = @stream.write(source) { |portion| @io.write portion }

            total_bytes_written += bytes_written
          end

          @pos += total_bytes_written

          total_bytes_written
        end

        def write_nonblock(object, *options)
          if @buffer.bytesize > 0
            # Write remaining buffer.
          end
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
