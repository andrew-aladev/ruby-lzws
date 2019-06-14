require "rake/testtask"

PREFIX = "tests".freeze

Rake::TestTask.new(:test_all) do |task|
  task.libs << ["lib"]

  pathes = `find #{PREFIX} | grep -P "\.test\.rb$"`
  task.test_files = pathes.split "\n"
end

task :all => :test_all
task :default => :test_all
