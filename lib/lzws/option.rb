# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

module LZWS
  module Option
    COMPRESSOR_DEFAULTS = {
      :max_code_bit_length  => 16,
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
