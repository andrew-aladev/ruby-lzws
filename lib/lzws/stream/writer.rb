# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "abstract"
require_relative "raw/compressor"

module LZWS
  module Stream
    class Writer < Abstract
      # It is not possible to maintain correspondance between bytes consumed from source and bytes written to destination.
      # So we will consume all source bytes and maintain buffer with remaining destination data.

      def initialize(destination_io, options = {}, *args)
        compressor = Raw::Compressor.new options

        super compressor, destination_io, *args
      end

      # -- synchronous --

      def write(*objects)
        write_remaining_buffer

        source_bytes_written = 0

        objects.each do |object|
          source = prepare_source_for_write object.to_s

          # Stream will write all data without any remainder.
          source_bytes_written += @raw_stream.write(source) { |portion| @io.write portion }
        end

        @pos += source_bytes_written

        source_bytes_written
      end

      def flush
        write_remaining_buffer

        @raw_stream.flush { |portion| @io.write portion }

        nil
      end

      protected def write_remaining_buffer
        return nil if @buffer.bytesize == 0

        @io.write @buffer

        reset_buffer
      end

      # -- asynchronous --

      def write_nonblock(object, *options)
        return 0 unless write_remaining_buffer_nonblock(*options)

        source = prepare_source_for_write object.to_s

        new_buffer           = self.class.new_buffer
        source_bytes_written = @raw_stream.write(source) { |portion| new_buffer << portion }

        # Buffer won't be affected if "write_nonblock" will raise an error.
        destination_bytes_written = @io.write_nonblock new_buffer, *options
        @buffer                   = new_buffer[destination_bytes_written..-1]

        @pos += source_bytes_written

        source_bytes_written
      end

      def flush_nonblock(*options)
        return false unless write_remaining_buffer_nonblock(*options)

        # @raw_stream.flush { |portion| @buffer << portion }

        true
      end

      protected def write_remaining_buffer_nonblock(*options)
        return true if @buffer.bytesize == 0

        destination_bytes_written = @io.write_nonblock @buffer, *options

        if destination_bytes_written != @buffer.bytesize
          @buffer = @buffer[destination_bytes_written..-1]
          return false
        end

        reset_buffer

        true
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
