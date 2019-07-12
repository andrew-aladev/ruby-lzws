# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

module LZWS
  module Stream
    module WriterHelpers
      def <<(object)
        write object
      end

      def print(*objects)
        if objects.empty?
          write $LAST_READ_LINE
          return nil
        end

        objects.each do |object|
          write object
          write $OUTPUT_FIELD_SEPARATOR unless $OUTPUT_FIELD_SEPARATOR.nil?
        end

        write $OUTPUT_RECORD_SEPARATOR unless $OUTPUT_RECORD_SEPARATOR.nil?

        nil
      end

      def printf(*args)
        write sprintf(*args)

        nil
      end

      # def putc
      # end

      # def puts
      # end
    end
  end
end
