# frozen_string_literal: true

require "pathname"
require "dnote/note"
require "dnote/notes_collection"

module DNote
  # = Developer Notes
  #
  # This class goes through you source files and compiles a list
  # of any labeled comments. Labels are all-cap single word prefixes
  # to a comment ending in a colon.
  #
  # Special labels do not require the colon. By default these are
  # +TODO+, +FIXME+, +OPTIMIZE+, +THINK+ and +DEPRECATE+.
  #
  #--
  #   TODO: Add ability to read header notes. They often
  #         have a outline format, rather then the single line.
  #++
  class Notes
    # Default paths (all ruby scripts).
    DEFAULT_PATHS  = ["**/*.rb"].freeze

    # Default note labels to look for in source code. (NOT CURRENTLY USED!)
    DEFAULT_LABELS = %w(TODO FIXME OPTIMIZE THINK DEPRECATE).freeze

    # Files to search for notes.
    attr_reader :files

    # Labels to document. Defaults are: +TODO+, +FIXME+, +OPTIMIZE+ and +DEPRECATE+.
    attr_reader :labels

    # Require label colon? Default is +true+.
    attr_reader :colon

    # Specific remark marker (+nil+ for auto).
    attr_reader :marker

    # Link template.
    attr_reader :url

    # Number of lines of context to show.
    attr_reader :context

    # New set of notes for give +files+ and optional special labels.
    def initialize(files, options = {})
      @files   = [files].flatten
      @labels  = [options[:labels] || DEFAULT_LABELS].flatten.compact
      @colon   = options[:colon].nil? ? true : options[:colon]
      @marker  = options[:marker]
      @url     = options[:url]
      @context = options[:context] || 0
      @remark  = {}

      parse
    end

    def notes_collection
      @notes_collection ||= NotesCollection.new(@notes)
    end

    # Gather notes.
    #--
    # TODO: Play golf with Notes#parse.
    #++
    def parse
      records = []
      files.each do |fname|
        records += parse_file(fname)
      end

      @notes = records.sort
    end

    def parse_file(fname)
      return [] unless File.file?(fname)

      records = []
      mark = remark(fname)
      lineno = 0
      note = nil
      text = nil
      capt = nil
      File.readlines(fname).each do |line|
        lineno += 1
        note = match(line, lineno, fname)
        if note
          text = note.text
          capt = note.capture
          records << note
        elsif text
          case line
          when /^\s*#{mark}+\s*$/, /^\s*#{mark}\-\-/, /^\s*#{mark}\+\+/
            text.strip!
            text = nil
          when /^\s*#{mark}/
            text << "\n" unless text[-1, 1] == "\n"
            text << line.gsub(/^\s*#{mark}\s*/, "")
          else
            text.strip!
            text = nil
          end
        elsif !/^\s*#{mark}/.match?(line)
          capt << line if capt && capt.size < context
        end
      end
      records
    end

    # Is this line a note?
    def match(line, lineno, file)
      if labels.empty?
        match_general(line, lineno, file)
      else
        match_special(line, lineno, file)
      end
    end

    # Match special notes.
    def match_special(line, lineno, file)
      rec = nil
      labels.each do |label|
        if (md = match_special_regex(label, file).match(line))
          text = md[1]
          rec = Note.new(self, file, label, lineno, text, remark(file))
        end
      end
      rec
    end

    def match_special_regex(label, file)
      mark = remark(file)
      label = Regexp.escape(label)
      if colon
        /#{mark}\s*#{label}[:]\s+(.*?)$/
      else
        /#{mark}\s*#{label}[:]?\s+(.*?)$/
      end
    end

    # Match notes that are labeled with a colon.
    def match_general(line, lineno, file)
      rec = nil
      if (md = match_general_regex(file).match(line))
        label = md[1]
        text = md[2]
        rec = Note.new(self, file, label, lineno, text, remark(file))
      end
      rec
    end

    # Keep in mind that general non-colon matches have a higher potential
    # of false positives.
    def match_general_regex(file)
      mark = remark(file)
      if colon
        /#{mark}\s*([A-Z]+)[:]\s+(.*?)$/
      else
        /#{mark}\s*([A-Z]+)\s+(.*?)$/
      end
    end

    def remark(file)
      @remark[File.extname(file)] ||= begin
        mark = guess_marker(file)
        Regexp.escape(mark)
      end
    end

    # Guess marker based on file extension. Fallsback to '#'
    # if the extension is unknown.
    #
    # TODO: Continue to add comment types.
    def guess_marker(file)
      return @marker if @marker # forced marker

      case File.extname(file)
      when ".js", ".c", "cpp", ".css"
        "//"
      when ".bas"
        "'"
      when ".sql", ".ada"
        "--"
      when ".asm"
        ";"
      else
        "#"
      end
    end
  end
end
