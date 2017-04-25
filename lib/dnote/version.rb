module DNote
  VERSION = '1.7.2'.freeze

  #
  def self.metadata
    @metadata ||= begin
      require 'yaml'
      YAML.load_file(File.dirname(__FILE__) + '/../dnote.yml')
    end
  end

  #
  def self.const_missing(name)
    metadata[name.to_s.downcase] || super(name)
  end
end
