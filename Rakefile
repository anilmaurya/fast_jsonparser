require "bundler/gem_tasks"
require "rake/testtask"
require "rake/extensiontask"

Rake::ExtensionTask.new("fast_jsonparser") do |ext|
  ext.ext_dir = 'ext/fast_jsonparser'
  ext.lib_dir = "lib/fast_jsonparser"
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test
