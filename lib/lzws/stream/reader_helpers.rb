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

        nil
      end

      def readbyte
        byte = getbyte
        raise ::EOFError if byte.nil?

        byte
      end

      def ungetbyte(byte)
        Validation.validate_string byte

        @buffer.prepend byte

        nil
      end

      # -- char --

      def getc
        if @external_encoding.nil?
          byte = getbyte
          return nil if byte.nil?

          return transcode_from_external_to_internal byte
        end

        bytes = ::String.new :encoding => ::Encoding::BINARY

        # Read one byte until valid string will appear.
        loop do
          byte = getbyte
          return nil if byte.nil?

          bytes << byte

          char = ::String.new bytes, :encoding => external_encoding_value
          return char if char.valid_encoding?
        end
      end

      def each_char(&block)
        return enum_for __method__ unless block.is_a? ::Proc

        loop do
          char = getc
          break if char.nil?

          yield char
        end

        nil
      end

      def readchar
        char = getc
        raise ::EOFError if char.nil?

        char
      end

      # Char is returning back to buffer.
      # "getc" method will return same char again.
      # WARNING - "getbyte" can return different bytes because of transcoding.
      def ungetc(char)
        Validation.validate_string char

        bytes = ::String.new char, :encoding => ::Encoding::BINARY
        @buffer.prepend bytes

        nil
      end

      # -- lines --

      def gets(separator = $OUTPUT_RECORD_SEPARATOR, limit = nil)
        # Limit can be a first argument.
        if separator.is_a? ::Numeric
          limit     = separator
          separator = $OUTPUT_RECORD_SEPARATOR
        end

        chars = ::String.new bytes, :encoding => external_encoding_value

        loop do
          char = getc
        end
      end

      # -- common --

      protected def external_encoding_value
        if @external_encoding.nil?
          ::Encoding::BINARY
        else
          @external_encoding
        end
      end

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
