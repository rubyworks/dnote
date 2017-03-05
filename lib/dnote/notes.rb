require 'pathname'
require 'dnote/note'

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
    include Enumerable

    # Default paths (all ruby scripts).
    DEFAULT_PATHS  = ['**/*.rb']

    # Default note labels to look for in source code. (NOT CURRENTLY USED!)
    DEFAULT_LABELS = ['TODO', 'FIXME', 'OPTIMIZE', 'THINK', 'DEPRECATE']

    # Files to search for notes.
    attr_accessor :files

    # Labels to document. Defaults are: +TODO+, +FIXME+, +OPTIMIZE+ and +DEPRECATE+.
    attr_accessor :labels

    # Require label colon? Default is +true+.
    attr_accessor :colon

    # Specific remark marker (+nil+ for auto).
    attr_accessor :marker

    # Link template.
    attr_accessor :url

    # Number of lines of context to show.
    attr_accessor :context

    # New set of notes for give +files+ and optional special labels.
    def initialize(files, options={})
      @files   = [files].flatten
      @labels  = [options[:labels] || DEFAULT_LABELS].flatten.compact
      @colon   = options[:colon].nil? ? true : options[:colon]
      @marker  = options[:marker] #|| '#'
      @url     = options[:url]
      @context = options[:context] || 0

      @remark  = {}

      parse
    end

    # Array of notes.
    def notes
      @notes
    end

    # Notes counts by label.
    def counts
      @counts ||= (
        h = {}
        by_label.each do |label, notes|
          h[label] = notes.size
        end
        h
      )
    end

    # Iterate through notes.
    def each(&block)
      notes.each(&block)
    end

    # No notes?
    def empty?
      notes.empty?
    end

    # Gather notes.
    #--
    # TODO: Play golf with Notes#parse.
    #++
    def parse
      records = []
      files.each do |fname|
        next unless File.file?(fname)
        mark = remark(fname)
        lineno, note, text, capt = 0, nil, nil, nil
        File.readlines(fname).each do |line|
          lineno += 1
          note = match(line, lineno, fname)
          if note
            text = note.text
            capt = note.capture
            records << note
          else
            if text
              case line
              when /^\s*#{mark}+\s*$/, /^\s*#{mark}\-\-/, /^\s*#{mark}\+\+/
                text.strip!
                text = nil
              when /^\s*#{mark}/
                if text[-1, 1] == "\n"
                  text << line.gsub(/^\s*#{mark}\s*/, '')
              else
                text << "\n" << line.gsub(/^\s*#{mark}\s*/, '')
                  end
              else
                text.strip!
                text = nil
              end
            else
              if line !~ /^\s*#{mark}/
                  capt << line if capt && capt.size < context
              end
            end
          end
        end
      end

      @notes = records.sort
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
        if md = match_special_regex(label, file).match(line)
          text = md[1]
          #rec = {'label'=>label,'file'=>file,'line'=>lineno,'note'=>text}
          rec = Note.new(self, file, label, lineno, text, remark(file))
        end
      end
      rec
    end

    #--
    # TODO: ruby-1.9.1-p378 reports: `match': invalid byte sequence in UTF-8
    #++
    def match_special_regex(label, file)
      mark = remark(file)
      if colon
        /#{mark}\s*#{Regexp.escape(label)}[:]\s+(.*?)$/
      else
        /#{mark}\s*#{Regexp.escape(label)}[:]?\s+(.*?)$/
      end
    end

    # Match notes that are labeled with a colon.
    def match_general(line, lineno, file)
      rec = nil
      if md = match_general_regex(file).match(line)
        label, text = md[1], md[2]
        rec = Note.new(self, file, label, lineno, text, remark(file))
      end
      return rec
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

    # Organize notes into a hash with labels for keys.
    def by_label
      @by_label ||= (
        list = {}
        notes.each do |note|
          list[note.label] ||= []
          list[note.label] << note
          list[note.label].sort #!{ |a,b| a.line <=> b.line }
        end
        list
      )
    end

    # Organize notes into a hash with filename for keys.
    def by_file
      @by_file ||= (
        list = {}
        notes.each do |note|
          list[note.file] ||= []
          list[note.file] << note
          list[note.file].sort! #!{ |a,b| a.line <=> b.line }
        end
        list
      )
    end

    # Organize notes into a hash with labels for keys, followed
    # by a hash with filename for keys.
    def by_label_file
      @by_label ||= (
        list = {}
        notes.each do |note|
          list[note.label] ||= {}
          list[note.label][note.file] ||= []
          list[note.label][note.file] << note
          list[note.label][note.file].sort! #{ |a,b| a.line <=> b.line }
        end
        list
      )
    end

    # Organize notes into a hash with filenames for keys, followed
    # by a hash with labels for keys.
    def by_file_label
      @by_file ||= (
        list = {}
        notes.each do |note|
          list[note.file] ||= {}
          list[note.file][note.label] ||= []
          list[note.file][note.label] << note
          list[note.file][note.label].sort! #{ |a,b| a.line <=> b.line }
        end
        list
      )
    end

    # Convert to an array of hashes.
    def to_a
      notes.map { |n| n.to_h }
    end

    # Same as #by_label.
    def to_h
      by_label
    end

    #
    def remark(file)
      @remark[File.extname(file)] ||= (
        mark = guess_marker(file)
        Regexp.escape(mark)
      )
    end

    # Guess marker based on file extension. Fallsback to '#'
    # if the extension is unknown.
    #
    # TODO: Continue to add comment types.
    def guess_marker(file)
      return @marker if @marker # forced marker
      case File.extname(file)
      when '.js', '.c', 'cpp', '.css'
        '//'
      when '.bas'
        "'"
      when '.sql', '.ada'
        '--'
      when '.asm'
        ';'
      else
        '#'
      end
    end
  end
end
