# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "error"

module LZWS
  module Validation
    IO_METHODS = %i[
      read
      write
      readpartial
      read_nonblock
      write_nonblock
      eof?
      flush
      close
      closed?
    ]
    .freeze

    def self.validate_bool(value)
      raise ValidateError, "invalid bool" unless value.is_a?(::TrueClass) || value.is_a?(::FalseClass)
    end

    def self.validate_positive_integer(value)
      raise ValidateError, "invalid positive integer" unless value.is_a?(::Integer) && value.positive?
    end

    def self.validate_not_negative_integer(value)
      raise ValidateError, "invalid not negative integer" unless value.is_a?(::Integer) && value >= 0
    end

    def self.validate_string(value)
      raise ValidateError, "invalid string" unless value.is_a? ::String
    end

    def self.validate_io(value)
      raise ValidateError, "invalid io" unless IO_METHODS.all? { |method| value.respond_to? method }
    end

    def self.validate_hash(value)
      raise ValidateError, "invalid hash" unless value.is_a? ::Hash
    end

    def self.validate_proc(value)
      unless value.is_a?(::Proc) || value.is_a?(::Method) || value.is_a?(::UnboundMethod)
        raise ValidateError, "invalid proc"
      end
    end
  end
end
