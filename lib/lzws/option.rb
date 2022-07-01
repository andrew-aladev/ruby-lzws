# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws_ext"

require_relative "error"
require_relative "validation"

module LZWS
  # LZWS::Option module.
  module Option
    DEFAULT_BUFFER_LENGTH = 0

    COMPRESSOR_DEFAULTS = {
      :gvl                  => false,
      :max_code_bit_length  => nil,
      :without_magic_header => nil,
      :block_mode           => nil,
      :msb                  => nil,
      :unaligned_bit_groups => nil,
      :quiet                => nil
    }
    .freeze

    DECOMPRESSOR_DEFAULTS = {
      :gvl                  => false,
      :without_magic_header => nil,
      :msb                  => nil,
      :unaligned_bit_groups => nil,
      :quiet                => nil
    }
    .freeze

    def self.get_compressor_options(options, buffer_length_names)
      Validation.validate_hash options

      buffer_length_defaults = buffer_length_names.each_with_object({}) do |name, defaults|
        defaults[name] = DEFAULT_BUFFER_LENGTH
      end

      options = COMPRESSOR_DEFAULTS.merge(buffer_length_defaults).merge options

      buffer_length_names.each { |name| Validation.validate_not_negative_integer options[name] }

      Validation.validate_bool options[:gvl]

      max_code_bit_length = options[:max_code_bit_length]
      unless max_code_bit_length.nil?
        Validation.validate_positive_integer max_code_bit_length
        raise ValidateError, "invalid max code bit length" if
          max_code_bit_length < LOWEST_MAX_CODE_BIT_LENGTH || max_code_bit_length > BIGGEST_MAX_CODE_BIT_LENGTH
      end

      without_magic_header = options[:without_magic_header]
      Validation.validate_bool without_magic_header unless without_magic_header.nil?

      block_mode = options[:block_mode]
      Validation.validate_bool block_mode unless block_mode.nil?

      msb = options[:msb]
      Validation.validate_bool msb unless msb.nil?

      unaligned_bit_groups = options[:unaligned_bit_groups]
      Validation.validate_bool unaligned_bit_groups unless unaligned_bit_groups.nil?

      quiet = options[:quiet]
      Validation.validate_bool quiet unless quiet.nil?

      options
    end

    def self.get_decompressor_options(options, buffer_length_names)
      Validation.validate_hash options

      buffer_length_defaults = buffer_length_names.each_with_object({}) do |name, defaults|
        defaults[name] = DEFAULT_BUFFER_LENGTH
      end

      options = DECOMPRESSOR_DEFAULTS.merge(buffer_length_defaults).merge options

      buffer_length_names.each { |name| Validation.validate_not_negative_integer options[name] }

      Validation.validate_bool options[:gvl]

      without_magic_header = options[:without_magic_header]
      Validation.validate_bool without_magic_header unless without_magic_header.nil?

      msb = options[:msb]
      Validation.validate_bool msb unless msb.nil?

      unaligned_bit_groups = options[:unaligned_bit_groups]
      Validation.validate_bool unaligned_bit_groups unless unaligned_bit_groups.nil?

      quiet = options[:quiet]
      Validation.validate_bool quiet unless quiet.nil?

      options
    end
  end
end
