# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

module LZWS
  class BaseError < ::StandardError; end

  class ValidateError   < BaseError; end
  class AllocateError   < BaseError; end
  class UnexpectedError < BaseError; end

  class NotEnoughDestinationError < BaseError; end
  class UsedAfterCloseError       < BaseError; end

  class DecompressorCorruptedSourceError < BaseError; end

  class OpenFileError < BaseError; end
  class AccessIOError < BaseError; end
  class ReadIOError   < BaseError; end
  class WriteIOError  < BaseError; end
end
