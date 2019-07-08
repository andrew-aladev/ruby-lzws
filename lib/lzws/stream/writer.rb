# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "abstract_io"
require_relative "compressor"
require_relative "../validation"

module LZWS
  module Stream
    class Writer < AbstractIO
      def initialize(destination_io, options = {}, *args)
        compressor = Compressor.new options

        super compressor, destination_io, *args
      end

      def write(*sources)
        # sources.each { |source| Validation.validate_string source }
        #
        # write_length = 0
        #
        # sources.each do |source|
        #   @processor.write(source) { |portion| @io.write portion }
        #
        #   write_length += source.length
        # end
        #
        # @pos += write_length
        #
        # write_length
      end

      # write_nonblock
    end
  end
end
