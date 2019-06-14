# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

module LZWS
  module Option
    # Default options will be compatible with UNIX compress.

    BIGGEST_MAX_CODE_BIT_LENGTH = 16

    COMPRESSOR_DEFAULTS = {
      :max_code_bit_length  => BIGGEST_MAX_CODE_BIT_LENGTH,
      :block_mode           => true,
      :msb                  => false,
      :unaligned_bit_groups => false,
      :quiet                => false
    }
    .freeze

    DECOMPRESSOR_DEFAULTS = {
      :msb                  => false,
      :unaligned_bit_groups => false,
      :quiet                => false
    }
    .freeze
  end
end
