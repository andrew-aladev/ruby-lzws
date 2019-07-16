# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "abstract"
require_relative "writer_helpers"
require_relative "raw/compressor"

module LZWS
  module Stream
    class Writer < Abstract
      include WriterHelpers

      def initialize(destination_io, options = {}, *args)
        @options = options

        super destination_io, *args
      end

      def create_raw_stream
        Raw::Compressor.new @options
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
        finish :flush

        super
      end

      def close
        finish :close

        super
      end

      protected def finish(method_name)
        write_remaining_buffer

        @raw_stream.send(method_name) { |portion| @io.write portion }
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

        # Current buffer won't be affected if "write_nonblock" will raise an error.
        # So same source can be provided again on the next method call.
        destination_bytes_written = @io.write_nonblock new_buffer, *options
        @buffer                   = new_buffer[destination_bytes_written..-1]

        @pos += source_bytes_written

        source_bytes_written
      end

      def flush_nonblock(*options)
        finish_nonblock :flush, *options

        flush
      end

      def close_nonblock(*options)
        finish_nonblock :close, *options

        close
      end

      protected def finish_nonblock(method_name, *options)
        return false unless write_remaining_buffer_nonblock(*options)

        @raw_stream.send(method_name) { |portion| @buffer << portion }

        # Current buffer will be written before "write_nonblock" call.
        # So remaining buffer will be written on the next method call.
        destination_bytes_written = @io.write_nonblock @buffer, *options
        @buffer                   = @buffer[destination_bytes_written..-1]

        @buffer.bytesize == 0
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
