# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "lzws/option"
require "ocg"

require_relative "validation"

module LZWS
  module Test
    module Option
      private_class_method def self.get_invalid_buffer_length_options(buffer_length_names, &_block)
        buffer_length_names.each do |name|
          (Validation::INVALID_NOT_NEGATIVE_INTEGERS - [nil]).each do |invalid_integer|
            yield({ name => invalid_integer })
          end
        end
      end

      def self.get_invalid_decompressor_options(buffer_length_names, &block)
        Validation::INVALID_HASHES.each do |invalid_hash|
          yield invalid_hash
        end

        get_invalid_buffer_length_options buffer_length_names, &block

        Validation::INVALID_BOOLS.each do |invalid_bool|
          yield({ :without_magic_header => invalid_bool })
          yield({ :msb                  => invalid_bool })
          yield({ :unaligned_bit_groups => invalid_bool })
          yield({ :quiet                => invalid_bool })
        end
      end

      def self.get_invalid_compressor_options(buffer_length_names, &block)
        get_invalid_decompressor_options buffer_length_names, &block

        Validation::INVALID_POSITIVE_INTEGERS.each do |invalid_integer|
          yield({ :max_code_bit_length => invalid_integer })
        end

        yield({ :max_code_bit_length => LZWS::Option::LOWEST_MAX_CODE_BIT_LENGTH - 1 })
        yield({ :max_code_bit_length => LZWS::Option::BIGGEST_MAX_CODE_BIT_LENGTH + 1 })

        Validation::INVALID_BOOLS.each do |invalid_bool|
          yield({ :block_mode => invalid_bool })
        end
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

      private_class_method def self.get_buffer_length_option_generator(buffer_length_names)
        OCG.new(
          Hash[buffer_length_names.map { |name| [name, BUFFER_LENGTHS] }]
        )
      end

      def self.get_compressor_options(buffer_length_names, &_block)
        buffer_length_generator = get_buffer_length_option_generator buffer_length_names

        main_generator = OCG.new(
          :max_code_bit_length  => MAX_CODE_BIT_LENGTHS,
          :block_mode           => BOOLS,
          :without_magic_header => BOOLS,
          :msb                  => BOOLS,
          :unaligned_bit_groups => BOOLS
        )

        other_generator = OCG.new(
          :quiet => BOOLS
        )

        complete_generator = buffer_length_generator.mix(main_generator).mix other_generator

        yield complete_generator.next until complete_generator.finished?
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
