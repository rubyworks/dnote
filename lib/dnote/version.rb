module DNote
  # Access to `version.yml` file.
  def self.version
    @version ||= (
      require 'yaml'
      YAML.load(File.new(File.dirname(__FILE__) + '/version.yml'))
    )
  end

  # Lookup constant in `version.yml`.
  def self.const_missing(name)
    key = name.to_s.downcase
    version[key] || super(name)
  end
end

