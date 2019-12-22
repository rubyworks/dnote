# frozen_string_literal: true

require "bundler/gem_tasks"
require "cucumber/rake/task"
require "rake/clean"
require "rake/testtask"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.ruby_opts = ["-Ilib -w"]
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format progress --color"
end

task default: :spec
task default: :features
