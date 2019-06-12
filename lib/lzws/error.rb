# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

module LZWS
  class BaseError < StandardError; end

  class CompressorFailedError < BaseError; end
  class DecompressorFailedError < BaseError; end
  class ReadFileFailedError < BaseError; end
  class WriteFileFailedError < BaseError; end
  class UnexpectedError < BaseError; end
end
