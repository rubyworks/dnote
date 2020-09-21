# frozen_string_literal: true

require "bundler/gem_tasks"
require "cucumber/rake/task"
require "rake/clean"
require "rake/testtask"
require "rspec/core/rake_task"
require "rake/manifest"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.ruby_opts = ["-Ilib -w"]
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format progress --color"
end

Rake::Manifest::Task.new do |t|
  t.patterns = ["lib/**/*", "COPYING.rdoc", "HISTORY.rdoc", "README.md", "bin/dnote"]
end

task default: :spec
task default: :features
task build: "manifest:check"
