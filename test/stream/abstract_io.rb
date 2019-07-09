# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require_relative "../minitest"
require_relative "../option"
require_relative "../validation"

module LZWS
  module Test
    module Stream
      class AbstractIO < Minitest::Unit::TestCase
        def test_invalid_initialize
          Validation::INVALID_IOS.each do |invalid_io|
            assert_raises ValidateError do
              target.new invalid_io
            end
          end

          Option::INVALID_DECOMPRESSOR_OPTIONS.each do |invalid_options|
            assert_raises ValidateError do
              target.new STDOUT, invalid_options
            end
          end

          (Validation::INVALID_STRINGS - [nil]).each do |invalid_string|
            assert_raises ValidateError do
              target.new STDOUT, {}, :external_encoding => invalid_string
            end

            assert_raises ValidateError do
              target.new STDOUT, {}, :internal_encoding => invalid_string
            end
          end

          Validation::INVALID_ENCODINGS.each do |invalid_encoding|
            assert_raises ValidateError do
              target.new STDOUT, {}, :external_encoding => invalid_encoding
            end

            assert_raises ValidateError do
              target.new STDOUT, {}, :internal_encoding => invalid_encoding
            end
          end

          (Validation::INVALID_HASHES - [nil]).each do |invalid_hash|
            assert_raises ValidateError do
              target.new STDOUT, {}, :transcode_options => invalid_hash
            end
          end
        end

        def test_invalid_set_encoding
          instance = target.new STDOUT

          (Validation::INVALID_STRINGS - [nil]).each do |invalid_string|
            assert_raises ValidateError do
              instance.set_encoding invalid_string
            end

            assert_raises ValidateError do
              instance.set_encoding Encoding::BINARY, invalid_string
            end
          end

          Validation::INVALID_ENCODINGS.each do |invalid_encoding|
            assert_raises ValidateError do
              instance.set_encoding invalid_encoding
            end

            assert_raises ValidateError do
              instance.set_encoding Encoding::BINARY, invalid_encoding
            end

            assert_raises ValidateError do
              instance.set_encoding "#{Encoding::BINARY}:#{invalid_encoding}"
            end

            assert_raises ValidateError do
              instance.set_encoding "#{invalid_encoding}:#{Encoding::BINARY}"
            end
          end

          (Validation::INVALID_HASHES - [nil]).each do |invalid_hash|
            assert_raises ValidateError do
              instance.set_encoding Encoding::BINARY, Encoding::BINARY, invalid_hash
            end
          end
        end

        # -----

        protected def target
          self.class::Target
        end
      end
    end
  end
end
