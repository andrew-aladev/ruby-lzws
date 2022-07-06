require "rake/extensiontask"
require "rake/testtask"
require "rdoc/task"
require "rubygems/package_task"

load "ruby-lzws.gemspec"

Rake::ExtensionTask.new do |ext|
  ext.name           = "lzws_ext"
  ext.ext_dir        = "ext"
  ext.lib_dir        = "lib"
  ext.tmp_dir        = "tmp"
  ext.source_pattern = "*.{c,h}"
end

Rake::TestTask.new do |task|
  task.libs << %w[lib]

  pathes          = `find test | grep "\.test\.rb$"`
  task.test_files = ["test/coverage_helper.rb"] + pathes.split("\n")
end

RDoc::Task.new do |rdoc|
  rdoc.title    = "Ruby LZWS rdoc"
  rdoc.main     = "README.md"
  rdoc.rdoc_dir = "docs"
  rdoc.rdoc_files.include(
    "lib/**/*.rb",
    "AUTHORS",
    "LICENSE",
    "README.md"
  )
end

task :default => %i[compile test]

Gem::PackageTask.new(GEMSPEC).define
