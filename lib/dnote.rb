module DNote
  VERSION = "1.1.2"  #:till: VERSION = "<%= version %>"

  require 'dnote/notes'

  # NOTE: Toying with the idea of making DNote a class.

  #attr :notes
  #
  #def initialize(paths, options={})
  #  labels = options[:labels] || options['labels']
  #  @notes = Notes.new(paths, labels)
  #end
  #
  #
  #def save(format, output, options)
  #  options = options.merge({ :format=>format, :output=>output })
  #  format = Format.new(notes, options)
  #  format.render
  #end
  #
  #
  #def display(format, options)
  #  options = options.merge({ :format=>format, :output=>nil })
  #  format  = Format.new(@notes, options)
  #  format.render
  #end

end

# TEST: This is a test of arbitraty labels.
