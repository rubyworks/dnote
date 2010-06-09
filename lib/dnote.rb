module DNote
  DIRECTORY = File.dirname(__FILE__) + '/dnote'

  profile = YAML.load(File.new(DIRECTORY + '/profile.yml'))
  verfile = YAML.load(File.new(DIRECTORY + '/version.yml'))

  VERSION = verfile.values_at('major','minor','patch','state','build').compact.join('.')

  #
  def const_missing(name)
    if verfile.key?(name.downcase)
      verfile[name.downcase]
    elsif profile.key?(name.downcase)
      profile[name.downcase]
    else
      super(name)
    end
  end
end

require 'dnote/session'

# TEST: This is a test of arbitraty labels.

