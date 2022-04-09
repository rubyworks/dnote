# frozen_string_literal: true

module DNote
  # The Note class encapsulates a single note made in a source file.
  #
  # Each note instance holds a reference, +notes+, to the set of notes
  # being generated for a given session. This allows the note to access
  # general options applicable to all notes.
  class Note
    # Set of notes to which this note belongs.
    attr_reader :notes

    # The file in which the note is made.
    attr_reader :file

    # The type of note.
    attr_reader :label

    # The line number of the note.
    attr_reader :line

    # The verbatim text of the note.
    attr_reader :text

    # Remark marker used in parsing the note.
    attr_reader :mark

    # Contextual lines of code.
    attr_reader :capture

    # Initialize new Note instance.
    def initialize(notes, file, label, line, text, mark)
      @notes = notes
      @file = file
      @label = label
      @line = line
      @text = text.rstrip
      @mark = mark
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
      text.tr("\n", " ")
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
      {"label" => label, "text" => textline, "file" => file, "line" => line}
    end

    # Convert to Hash, leaving the note text verbatim.
    def to_h_raw
      {"label" => label, "text" => text, "file" => file, "line" => line, "code" => code}
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
    #
    # FIXME: Move out of Note so we can drop the reference to notes
    def url
      if notes.url
        format(notes.url, file, line)
      else
        file
      end
    end

    def code
      unindent(capture).join
    end

    # Is there code to show?
    def code?
      !capture.empty?
    end

    private

    # Remove blank space from lines.
    def unindent(lines)
      dents = []
      lines.each do |line|
        if (md = /^(\ *)/.match(line))
          dents << md[1]
        end
      end
      dent = dents.min_by(&:size)
      lines.map do |line|
        line.sub(dent, "")
      end
    end
  end
end
