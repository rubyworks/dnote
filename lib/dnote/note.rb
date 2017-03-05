module DNote

  # The Note class encapsulates a single note made in a source file.
  #
  # Each note instance holds a reference, +notes+, to the set of notes
  # being generated for a given session. This allows the note to access
  # general options applicable to all notes.
  class Note

    # Number of lines to provide in source context.
    #CONTEXT_DEPTH = 5

    # Set of notes to which this note belongs.
    attr :notes

    # The file in which the note is made.
    attr :file

    # The type of note.
    attr :label

    # The line number of the note.
    attr :line

    # The verbatim text of the note.
    attr :text

    # Remark marker used in parsing the note.
    attr :mark

    # Contextual lines of code.
    attr :capture

    # Initialize new Note instance.
    def initialize(notes, file, label, line, text, mark)
      @notes   = notes

      @file    = file
      @label   = label
      @line    = line
      @text    = text.rstrip
      @mark    = mark
      @capture = []
    end

    # Convert to string representation.
    def to_s
      "#{label}: #{text}"
    end

    # Convert to string representation.
    def to_str
      "#{label}: #{text}"
    end

    # Remove newlines from note text.
    def textline
      text.gsub("\n", ' ')
    end

    # Sort by file name and line number.
    def <=>(other)
      s = file <=> other.file
      return s unless s == 0
      line <=> other.line
    end

    # Convert to Hash.
    #--
    # TODO: Add +url+?
    # TODO: Add +code+? Problem is that xml needs code in CDATA.
    #++
    def to_h
      { 'label' => label, 'text' => textline, 'file' => file, 'line' => line }
    end

    # Convert to Hash, leaving the note text verbatim.
    def to_h_raw
      { 'label' => label, 'text' => text, 'file' => file, 'line' => line, 'code' => code }
    end

    # Convert to JSON.
    def to_json(*args)
      to_h_raw.to_json(*args)
    end

    # Convert to YAML.
    def to_yaml(*args)
      to_h_raw.to_yaml(*args)
    end

    # Return line URL based on URL template. If no template was set, then
    # returns the file.
    def url
      if notes.url
        notes.url % [file, line]
      else
        file
      end
    end

    #
    def code
      unindent(capture).join
    end

    # Is there code to show?
    def code?
      !capture.empty?
    end

=begin
    # This isn't being used currently b/c the URL solution as deeemd better,
    # but the code is here for custom templates.
    def capture
      @context ||= (
        lines = file_cache(file) #.lines.to_a
        count = line()
        count +=1 while /^\s*#{mark}/ =~ lines[count]
        lines[count, context_depth]
      )
    end

    # Read in +file+, parse into lines and cache.
    def file_cache(file)
      @@file_cache ||= {}
      @@file_cache[file] ||= File.read(file).lines.to_a
    end
=end

    private

    # Remove blank space from lines.
    def unindent(lines)
      dents = []
      lines.each do |line|
        if md = /^([\ ]*)/.match(line)
          size = md[1].size
          dents << md[1]
        end
      end
      dent = dents.min{ |a, b| a.size <=> b.size }
      lines.map do |line|
        line.sub(dent, '')
      end
    end

  end

end
