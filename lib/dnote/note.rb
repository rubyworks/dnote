module DNote

  #
  class Note
    attr :file
    attr :label
    attr :line
    attr :text

    def initialize(file, label, line, text)
      @file  = file
      @label = label
      @line  = line
      @text  = text.rstrip
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
  end

end

