# frozen_string_literal: true

require "rake/file_list"
require File.join(__dir__, "lib/dnote/version")

Gem::Specification.new do |s|
  s.name = "mvz-dnote"
  s.version = DNote::VERSION
  s.summary = "Extract developer's notes from source code."
  s.authors = ["Thomas Sawyer", "Matijs van Zuijlen"]
  s.email = ["matijs@matijs.net"]
  s.homepage = "https://github.com/mvz/dnote"

  s.required_ruby_version = ">= 2.5.0"

  s.license = "BSD-2-Clause"

  s.description = <<~DESC
    DNote makes it easy to extract developer's notes from source code,
    and supports almost any language.
  DESC

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = "https://github.com/mvz/dnote"
  s.metadata["changelog_uri"] = "https://github.com/mvz/dnote/blob/master/HISTORY.rdoc"

  s.files =
    Rake::FileList["lib/**/*", "COPYING.rdoc", "HISTORY.rdoc", "README.md", "bin/dnote"]
    .exclude(*File.read(".gitignore").split)
  s.rdoc_options = ["--main", "README.md"]
  s.extra_rdoc_files = ["HISTORY.rdoc", "README.md", "COPYING.rdoc"]

  s.bindir = "bin"
  s.executables = ["dnote"]

  s.add_development_dependency("aruba", ["~> 1.0"])
  s.add_development_dependency("cucumber", ["~> 5.0"])
  s.add_development_dependency("pry", ["~> 0.13.0"])
  s.add_development_dependency("rake", ["~> 13.0"])
  s.add_development_dependency("rspec", ["~> 3.5"])
  s.add_development_dependency("rubocop", ["~> 0.91.0"])
  s.add_development_dependency("rubocop-packaging", ["~> 0.5.0"])
  s.add_development_dependency("rubocop-performance", ["~> 1.8.0"])
  s.add_development_dependency("rubocop-rspec", ["~> 1.43.1"])
  s.add_development_dependency("simplecov", ["~> 0.19.0"])

  s.require_paths = ["lib"]
end
