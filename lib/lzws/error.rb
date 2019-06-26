# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

module LZWS
  class BaseError < StandardError; end

  class CompressorError   < BaseError; end
  class DecompressorError < BaseError; end

  class OpenFileError < BaseError; end
  class AccessIOError < BaseError; end
  class ReadIOError   < BaseError; end
  class WriteIOError  < BaseError; end

  class AllocateError   < BaseError; end
  class ValidateError   < BaseError; end
  class UnexpectedError < BaseError; end
end
