# Ruby bindings for lzws library.
# Copyright (c) 2019 AUTHORS, MIT License.

require "date"

require_relative "lib/lzws/version"

Gem::Specification.new do |gem|
  gem.name     = "ruby-lzws"
  gem.summary  = "Ruby bindings for lzws library."
  gem.homepage = "https://github.com/andrew-aladev/ruby-lzws"
  gem.license  = "MIT"
  gem.authors  = File.read("AUTHORS").split("\n").reject(&:empty?)
  gem.email    = "aladjev.andrew@gmail.com"
  gem.version  = LZWS::VERSION
  gem.date     = Date.today.to_s

  gem.add_development_dependency "minitest"
  gem.add_development_dependency "rake-compiler"
  gem.add_development_dependency "rubocop"
  gem.add_development_dependency "rubocop-performance"
  gem.add_development_dependency "rubocop-rails"

  gem.files = \
    `git ls-files -z --directory {ext,lib}`.split("\x0") + \
    %w[AUTHORS LICENSE README.md]
  gem.require_paths = %w[lib]
  gem.extensions    = %w[ext/extconf.rb]
end
