require 'dnote/notes'

module DNote
  VERSION = "0.8"  #:till: VERSION = "<%= version %>"

  def self.new(*args)
    Notes.new(*args)
  end
end

