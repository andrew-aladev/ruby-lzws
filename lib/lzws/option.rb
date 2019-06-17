# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "error"

module LZWS
  module Option
    # Default options will be compatible with UNIX compress.

    LOWEST_MAX_CODE_BIT_LENGTH  = 9
    BIGGEST_MAX_CODE_BIT_LENGTH = 16

    DECOMPRESSOR_DEFAULTS = {
      :msb                  => false,
      :unaligned_bit_groups => false,
      :quiet                => false
    }
    .freeze

    COMPRESSOR_DEFAULTS = DECOMPRESSOR_DEFAULTS.merge(
      :max_code_bit_length => BIGGEST_MAX_CODE_BIT_LENGTH,
      :block_mode          => true
    )
    .freeze

    def self.get_compressor_options(options)
      raise UnexpectedArgumentError unless options.is_a? ::Hash

      options = COMPRESSOR_DEFAULTS.merge options
      raise UnexpectedArgumentError unless compressor_options_valid? options

      options
    end

    def self.get_decompressor_options(options)
      raise UnexpectedArgumentError unless options.is_a? ::Hash

      options = DECOMPRESSOR_DEFAULTS.merge options
      raise UnexpectedArgumentError unless decompressor_options_valid? options

      options
    end

    private_class_method def self.compressor_options_valid?(options)
      return false unless options.is_a? ::Hash

      max_code_bit_length = options[:max_code_bit_length]
      return false unless
        max_code_bit_length.is_a?(::Integer) &&
        max_code_bit_length >= LOWEST_MAX_CODE_BIT_LENGTH &&
        max_code_bit_length <= BIGGEST_MAX_CODE_BIT_LENGTH

      (
        bool?(options[:block_mode]) &&
        bool?(options[:msb]) &&
        bool?(options[:unaligned_bit_groups]) &&
        bool?(options[:quiet])
      )
    end

    private_class_method def self.decompressor_options_valid?(options)
      return false unless options.is_a? ::Hash

      (
        bool?(options[:msb]) &&
        bool?(options[:unaligned_bit_groups]) &&
        bool?(options[:quiet])
      )
    end

    private_class_method def self.bool?(value)
      value.is_a?(::TrueClass) || value.is_a?(::FalseClass)
    end
  end
end
