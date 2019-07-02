# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "error"
require_relative "validation"

module LZWS
  module Option
    # Default options will be compatible with UNIX compress.

    LOWEST_MAX_CODE_BIT_LENGTH  = 9
    BIGGEST_MAX_CODE_BIT_LENGTH = 16

    DECOMPRESSOR_DEFAULTS = {
      :without_magic_header => false,
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
      Validation.validate_hash options

      options = COMPRESSOR_DEFAULTS.merge options

      max_code_bit_length = options[:max_code_bit_length]
      Validation.validate_integer max_code_bit_length

      raise ValidateError if
        max_code_bit_length < LOWEST_MAX_CODE_BIT_LENGTH ||
        max_code_bit_length > BIGGEST_MAX_CODE_BIT_LENGTH

      Validation.validate_bool options[:without_magic_header]
      Validation.validate_bool options[:block_mode]
      Validation.validate_bool options[:msb]
      Validation.validate_bool options[:unaligned_bit_groups]
      Validation.validate_bool options[:quiet]

      options
    end

    def self.get_decompressor_options(options)
      Validation.validate_hash options

      options = DECOMPRESSOR_DEFAULTS.merge options

      Validation.validate_bool options[:without_magic_header]
      Validation.validate_bool options[:msb]
      Validation.validate_bool options[:unaligned_bit_groups]
      Validation.validate_bool options[:quiet]

      options
    end
  end
end
