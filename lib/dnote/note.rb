module DNote

  #
  class Note

    #
    CONTEXT_DEPTH = 3

    # Set of notes to which this note belongs.
    attr :notes

    attr :file
    attr :label
    attr :line
    attr :text
    attr :mark

    #
    def initialize(notes, file, label, line, text, mark)
      @notes   = notes

      @file    = file
      @label   = label
      @line    = line
      @text    = text.rstrip
      @mark    = mark
    end

    #
    def to_s
      "#{label}: #{text}"
    end

    #
    def to_str
      "#{label}: #{text}"
    end

    #
    def textline
      text.gsub("\n", " ")
    end

    # Sort by file name and line number.
    def <=>(other)
      s = file <=> other.file
      return s unless s == 0
      line <=> other.line
    end

    def to_h
      { 'label'=>label, 'text'=>textline, 'file'=>file, 'line'=>line }
    end

    def to_h_raw
      { 'label'=>label, 'text'=>text, 'file'=>file, 'line'=>line }
    end

    def to_json(*args)
      to_h_raw.to_json(*args)
    end

    def to_yaml(*args)
      to_h_raw.to_yaml(*args)
    end

    #
    def url
      if notes.url
        notes.url % [file, line]
      else
        file
      end
    end

    # DEPRECATE: URL solution is better.
    def context
      @context ||= (
        lines = file_cache(file) #.lines.to_a
        count = line()
        count +=1 while /^\s*#{mark}/ =~ lines[count]
        lines[count, CONTEXT_DEPTH]
      )
    end

    #
    def file_cache(file)
      @@file_cache ||= {}
      @@file_cache[file] ||= File.read(file).lines.to_a
    end

  end

end
