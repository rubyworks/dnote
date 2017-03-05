module DNote
  VERSION = '1.7.2'

  #
  def self.metadata
    @metadata ||= (
      require 'yaml'
      YAML.load_file(File.dirname(__FILE__) + '/../dnote.yml')
    )
  end

  #
  def self.const_missing(name)
    metadata[name.to_s.downcase] || super(name)
  end
end
