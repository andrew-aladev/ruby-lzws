# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/option"

require_relative "validation"

module LZWS
  module Test
    module Option
      private_class_method def self.get_invalid_buffer_length_options(buffer_length_names)
        buffer_length_names.flat_map do |name|
          (Validation::INVALID_NOT_NEGATIVE_INTEGERS - [nil]).map do |invalid_integer|
            { name => invalid_integer }
          end
        end
      end

      def self.get_invalid_decompressor_options(buffer_length_names)
        [
          Validation::INVALID_HASHES,
          get_invalid_buffer_length_options(buffer_length_names),
          Validation::INVALID_BOOLS.flat_map do |invalid_bool|
            [
              { :without_magic_header => invalid_bool },
              { :msb => invalid_bool },
              { :unaligned_bit_groups => invalid_bool },
              { :quiet => invalid_bool }
            ]
          end
        ]
        .flatten 1
      end

      def self.get_invalid_compressor_options(buffer_length_names)
        [
          get_invalid_decompressor_options(buffer_length_names),
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
        .flatten 1
      end

      # -----

      # "0" means default buffer length.
      # "2" bytes is the minimal buffer length for compressor and decompressor.
      BUFFER_LENGTHS = [
        0,
        2
      ]
      .freeze

      BOOLS = [
        true,
        false
      ]
      .freeze

      MAX_CODE_BIT_LENGTHS = Range.new(
        LZWS::Option::LOWEST_MAX_CODE_BIT_LENGTH,
        LZWS::Option::BIGGEST_MAX_CODE_BIT_LENGTH
      )
      .freeze

      private_class_method def self.get_buffer_length_option_data(buffer_length_names)
        buffer_length_names.map do |name|
          BUFFER_LENGTHS.map do |buffer_length|
            { name => buffer_length }
          end
        end
      end

      private_class_method def self.get_compressor_option_data(buffer_length_names)
        [
          get_buffer_length_option_data(buffer_length_names),
          [
            MAX_CODE_BIT_LENGTHS.map do |max_code_bit_length|
              { :max_code_bit_length => max_code_bit_length }
            end,
            BOOLS.map do |block_mode|
              { :block_mode => block_mode }
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
        ]
        .flatten 1
      end

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

      def self.get_compressor_option_combinations(buffer_length_names)
        get_option_combinations get_compressor_option_data(buffer_length_names)
      end

      def self.get_compatible_decompressor_options(compressor_options, buffer_length_name_mapping, &_block)
        decompressor_options = {
          :without_magic_header => compressor_options[:without_magic_header],
          :msb                  => compressor_options[:msb],
          :unaligned_bit_groups => compressor_options[:unaligned_bit_groups]
        }

        buffer_length_name_mapping.each do |compressor_name, decompressor_name|
          decompressor_options[decompressor_name] = compressor_options[compressor_name]
        end

        yield decompressor_options
      end
    end
  end
end
