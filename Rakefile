require 'bundler/gem_tasks'
require 'rake/clean'
require 'rake/testtask'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.ruby_opts = ['-Ilib -w']
end

task default: :spec
