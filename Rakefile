require 'bundler/gem_tasks'
require 'rake/clean'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs = ['lib']
  t.ruby_opts += ["-w -Itest"]
  t.test_files = FileList['test/**/*.rb']
end
