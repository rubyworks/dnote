require 'dnote/notes'

module DNote
  VERSION = "1.0"  #:till: VERSION = "<%= version %>"

  def self.new(*args)
    Notes.new(*args)
  end
end

# TEST: This is a test of arbitraty note labels.
