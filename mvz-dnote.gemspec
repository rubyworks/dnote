# frozen_string_literal: true

require_relative "lib/dnote/version"

Gem::Specification.new do |spec|
  spec.name = "mvz-dnote"
  spec.version = DNote::VERSION
  spec.authors = ["Thomas Sawyer", "Matijs van Zuijlen"]
  spec.email = ["matijs@matijs.net"]

  spec.summary = "Extract developer's notes from source code."
  spec.description = <<~DESC
    DNote makes it easy to extract developer's notes from source code,
    and supports almost any language.
  DESC
  spec.homepage = "https://github.com/mvz/dnote"
  spec.license = "BSD-2-Clause"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mvz/dnote"
  spec.metadata["changelog_uri"] = "https://github.com/mvz/dnote/blob/master/HISTORY.rdoc"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = File.readlines("Manifest.txt", chomp: true)
  spec.bindir = "bin"
  spec.executables = ["dnote"]
  spec.require_paths = ["lib"]

  spec.rdoc_options = ["--main", "README.md"]
  spec.extra_rdoc_files = ["HISTORY.rdoc", "README.md", "COPYING.rdoc"]

  spec.add_development_dependency "aruba", "~> 2.0"
  spec.add_development_dependency "cucumber", "~> 7.0"
  spec.add_development_dependency "pry", "~> 0.14.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rake-manifest", "~> 0.2.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rubocop", "~> 1.26.0"
  spec.add_development_dependency "rubocop-packaging", "~> 0.5.0"
  spec.add_development_dependency "rubocop-performance", "~> 1.13.0"
  spec.add_development_dependency "rubocop-rspec", "~> 2.9.0"
  spec.add_development_dependency "simplecov", "~> 0.21.0"
end
