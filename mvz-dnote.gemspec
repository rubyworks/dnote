# frozen_string_literal: true

require File.join(File.dirname(__FILE__), "lib/dnote/version.rb")

Gem::Specification.new do |s|
  s.name = "mvz-dnote"
  s.version = DNote::VERSION

  s.summary = "Extract developer's notes from source code."
  s.required_ruby_version = ">= 2.4.0"

  s.authors = ["Thomas Sawyer", "Matijs van Zuijlen"]
  s.email = ["matijs@matijs.net"]
  s.homepage = "https://github.com/mvz/dnote"

  s.description = <<-DESC
    DNote makes it easy to extract developer's notes from source code,
    and supports almost any language.
  DESC

  s.files = Dir["lib/**/*",
                "COPYING.rdoc",
                "HISTORY.rdoc",
                "README.md",
                "bin/dnote"] & `git ls-files -z`.split("\0")
  s.executables = ["dnote"]
  s.extra_rdoc_files = ["HISTORY.rdoc", "README.md", "COPYING.rdoc"]

  s.add_development_dependency("aruba", ["~> 0.14.1"])
  s.add_development_dependency("cucumber", ["~> 3.0"])
  s.add_development_dependency("pry", ["~> 0.12.2"])
  s.add_development_dependency("rake", ["~> 13.0"])
  s.add_development_dependency("rspec", ["~> 3.5"])
  s.add_development_dependency("simplecov", ["~> 0.18.0"])

  s.require_paths = ["lib"]
end
