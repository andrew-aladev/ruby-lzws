# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "codecov"
require "simplecov"

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Codecov
  ]
)

SimpleCov.start do
  add_filter %r{^/test/}
end
