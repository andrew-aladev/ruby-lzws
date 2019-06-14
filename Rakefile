require "rake/testtask"

Rake::TestTask.new(:test_all) do |task|
  task.libs << %w[ext lib]

  pathes = `find tests | grep -P "\.test\.rb$"`
  task.test_files = pathes.split "\n"
end

task :all => :test_all

task :default => :test_all
