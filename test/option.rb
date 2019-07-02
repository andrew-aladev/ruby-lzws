# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/option"

require_relative "validation"

module LZWS
  module Test
    module Option
      INVALID_DECOMPRESSOR_OPTIONS = [
        Validation::INVALID_HASHES,
        Validation::INVALID_BOOLS.flat_map do |invalid_bool|
          [
            { :without_magic_header => invalid_bool },
            { :msb => invalid_bool },
            { :unaligned_bit_groups => invalid_bool },
            { :quiet => invalid_bool }
          ]
        end
      ]
      .flatten(1)
      .freeze

      INVALID_COMPRESSOR_OPTIONS = [
        INVALID_DECOMPRESSOR_OPTIONS,
        [
          { :max_code_bit_length => LZWS::Option::LOWEST_MAX_CODE_BIT_LENGTH - 1 },
          { :max_code_bit_length => LZWS::Option::BIGGEST_MAX_CODE_BIT_LENGTH + 1 }
        ],
        Validation::INVALID_POSITIVE_INTEGERS.map do |invalid_positive_integer|
          { :max_code_bit_length => invalid_positive_integer }
        end,
        Validation::INVALID_BOOLS.map do |invalid_bool|
          { :block_mode => invalid_bool }
        end
      ]
      .flatten(1)
      .freeze

      # -----

      DECOMPRESSOR_OPTION_DATA = [
        [true, false].map do |value|
          { :without_magic_header => value }
        end,
        [true, false].map do |value|
          { :msb => value }
        end,
        [true, false].map do |value|
          { :unaligned_bit_groups => value }
        end,
        [true, false].map do |value|
          { :quiet => value }
        end
      ]
      .freeze

      COMPRESSOR_OPTION_DATA = [
        DECOMPRESSOR_OPTION_DATA,
        [
          Range.new(LZWS::Option::LOWEST_MAX_CODE_BIT_LENGTH, LZWS::Option::BIGGEST_MAX_CODE_BIT_LENGTH).map do |value|
            { :max_code_bit_length => value }
          end,
          [true, false].map do |value|
            { :block_mode => value }
          end
        ]
      ]
      .flatten(1)
      .freeze

      private_class_method def self.get_option_combinations(data)
        combinations = data
          .inject([]) do |result, array|
            next array if result.empty?

            result
              .product(array)
              .map(&:flatten)
          end

        combinations.map do |options|
          options.reduce({}, :merge)
        end
      end

      DECOMPRESSOR_OPTION_COMBINATIONS = get_option_combinations(DECOMPRESSOR_OPTION_DATA).freeze
      COMPRESSOR_OPTION_COMBINATIONS   = get_option_combinations(COMPRESSOR_OPTION_DATA).freeze

      COMPATIBLE_OPTION_COMBINATIONS = (
        COMPRESSOR_OPTION_COMBINATIONS.map do |compressor_options|
          decompressor_options = {
            :without_magic_header => compressor_options[:without_magic_header],
            :msb                  => compressor_options[:msb],
            :unaligned_bit_groups => compressor_options[:unaligned_bit_groups],
            :quiet                => compressor_options[:quiet]
          }
          [compressor_options, decompressor_options]
        end
      )
      .freeze
    end
  end
end
