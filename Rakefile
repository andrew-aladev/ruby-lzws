require "rake/extensiontask"
require "rake/testtask"

Rake::ExtensionTask.new do |ext|
  ext.name           = "lzws_ext"
  ext.ext_dir        = "ext"
  ext.lib_dir        = "lib"
  ext.tmp_dir        = "tmp"
  ext.source_pattern = "*.{c,h}"
end

Rake::TestTask.new do |task|
  task.libs << %w[lib]

  pathes = `find test | grep -P "\.test\.rb$"`
  task.test_files = pathes.split "\n"
end

task :default => %i[compile test]
