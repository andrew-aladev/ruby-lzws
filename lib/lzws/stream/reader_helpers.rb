# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "../error"
require_relative "../validation"

module LZWS
  module Stream
    module ReaderHelpers
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
