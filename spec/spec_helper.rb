# frozen_string_literal: true

require "simplecov"
SimpleCov.start

if ENV["CI"]
  begin
    require "coveralls"
    Coveralls.wear!
  rescue LoadError
    nil
  end
end

require "dnote"
require "dnote/rake/dnotetask"
