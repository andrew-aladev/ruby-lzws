# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "error"
require_relative "validation"

module LZWS
  module Option
    # Default options will be compatible with UNIX compress.

    DEFAULT_BUFFER_LENGTH       = 0
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

    def self.get_compressor_options(options, buffer_length_names)
      Validation.validate_hash options

      buffer_length_defaults = buffer_length_names.each_with_object({}) { |name, defaults| defaults[name] = DEFAULT_BUFFER_LENGTH }
      options                = COMPRESSOR_DEFAULTS.merge(buffer_length_defaults).merge options

      buffer_length_names.each { |name| Validation.validate_not_negative_integer options[name] }

      max_code_bit_length = options[:max_code_bit_length]
      Validation.validate_positive_integer max_code_bit_length

      raise ValidateError, "invalid max code bit length" if
        max_code_bit_length < LOWEST_MAX_CODE_BIT_LENGTH || max_code_bit_length > BIGGEST_MAX_CODE_BIT_LENGTH

      Validation.validate_bool options[:without_magic_header]
      Validation.validate_bool options[:block_mode]
      Validation.validate_bool options[:msb]
      Validation.validate_bool options[:unaligned_bit_groups]
      Validation.validate_bool options[:quiet]

      options
    end

    def self.get_decompressor_options(options, buffer_length_names)
      Validation.validate_hash options

      buffer_length_defaults = buffer_length_names.each_with_object({}) { |name, defaults| defaults[name] = DEFAULT_BUFFER_LENGTH }
      options                = DECOMPRESSOR_DEFAULTS.merge(buffer_length_defaults).merge options

      buffer_length_names.each { |name| Validation.validate_not_negative_integer options[name] }

      Validation.validate_bool options[:without_magic_header]
      Validation.validate_bool options[:msb]
      Validation.validate_bool options[:unaligned_bit_groups]
      Validation.validate_bool options[:quiet]

      options
    end
  end
end
