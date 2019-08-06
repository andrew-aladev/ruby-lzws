# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "../validation"

module LZWS
  module Stream
    module ReaderHelpers
      # -- byte --

      def getbyte
        read 1
      end

      def each_byte(&block)
        return enum_for __method__ unless block.is_a? ::Proc

        loop do
          byte = getbyte
          break if byte.nil?

          yield byte
        end
      end

      def readbyte
        byte = getbyte
        raise ::EOFError if byte.nil?

        byte
      end

      def ungetbyte(string)
        Validation.validate_string string
        @buffer.prepend string
      end

      # -- char --

      def getc
        bytes = ::String.new :encoding => ::Encoding::BINARY

        # Read one byte until valid string will appear.
        loop do
          byte = getbyte
          return nil if byte.nil?

          bytes << byte

          result = ::String.new bytes, :encoding => @external_encoding
          return result if result.valid_encoding?
        end
      end

      def each_char(&block)
        return enum_for __method__ unless block.is_a? ::Proc

        loop do
          char = getc
          break if char.nil?

          yield char
        end
      end

      def readchar
        char = getc
        raise ::EOFError if char.nil?

        char
      end

      def ungetc(string)
        Validation.validate_string string
        @buffer.prepend string
      end

      # -- lines --

      # -- etc --

      module ClassMethods
        def open(file_path, *args, &block)
          Validation.validate_string file_path
          Validation.validate_proc block

          ::File.open file_path, "rb" do |file|
            reader = new file, *args

            begin
              yield reader
            ensure
              reader.close
            end
          end
        end
      end

      def self.included(klass)
        klass.extend ClassMethods
      end
    end
  end
end
