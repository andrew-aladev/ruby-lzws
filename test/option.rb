# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/option"

require_relative "validation"

module LZWS
  module Test
    module Option
      INVALID_DECOMPRESSOR_OPTIONS = [
        Validation::INVALID_HASHES,
        Validation::INVALID_NOT_NEGATIVE_INTEGERS.map do |invalid_integer|
          { :buffer_length => invalid_integer }
        end,
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
        Validation::INVALID_POSITIVE_INTEGERS.map do |invalid_integer|
          { :max_code_bit_length => invalid_integer }
        end,
        Validation::INVALID_BOOLS.map do |invalid_bool|
          { :block_mode => invalid_bool }
        end
      ]
      .flatten(1)
      .freeze

      # -----

      # "0" means default buffer length.
      # "2" bytes is the minimal buffer length for compressor and decompressor.
      # "3" bytes should be enough for reading/writing magic and regular header.
      BUFFER_LENGTHS = [
        0,
        2,
        3,
        512
      ]
      .freeze
      BOOLS = [true, false].freeze
      MAX_CODE_BIT_LENGTHS = Range.new(
        LZWS::Option::LOWEST_MAX_CODE_BIT_LENGTH,
        LZWS::Option::BIGGEST_MAX_CODE_BIT_LENGTH
      )
      .freeze

      DECOMPRESSOR_OPTION_DATA = [
        BUFFER_LENGTHS.map do |buffer_length|
          { :buffer_length => buffer_length }
        end,
        BOOLS.map do |without_magic_header|
          { :without_magic_header => without_magic_header }
        end,
        BOOLS.map do |msb|
          { :msb => msb }
        end,
        BOOLS.map do |unaligned_bit_groups|
          { :unaligned_bit_groups => unaligned_bit_groups }
        end
      ]
      .freeze

      COMPRESSOR_OPTION_DATA = [
        DECOMPRESSOR_OPTION_DATA,
        [
          MAX_CODE_BIT_LENGTHS.map do |max_code_bit_length|
            { :max_code_bit_length => max_code_bit_length }
          end,
          BOOLS.map do |block_mode|
            { :block_mode => block_mode }
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
            :buffer_length        => compressor_options[:buffer_length],
            :without_magic_header => compressor_options[:without_magic_header],
            :msb                  => compressor_options[:msb],
            :unaligned_bit_groups => compressor_options[:unaligned_bit_groups]
          }
          [compressor_options, decompressor_options]
        end
      )
      .freeze
    end
  end
end
