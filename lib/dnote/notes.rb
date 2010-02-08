require 'pathname'

module DNote

  # = Developer Notes
  #
  # This class goes through you source files and compiles a list
  # of any labeled comments. Labels are single word prefixes to
  # a comment ending in a colon.
  #
  # By default the labels supported are TODO, FIXME, OPTIMIZE
  # and DEPRECATE.
  #
  #--
  #   TODO: Add ability to read header notes. They often
  #         have a outline format, rather then the single line.
  #++
  class Notes
    include Enumerable

    # Default paths (all ruby scripts).
    DEFAULT_PATHS  = ["**/*.rb"]

    # Default note labels to look for in source code.
    DEFAULT_LABELS = ['TODO', 'FIXME', 'OPTIMIZE', 'DEPRECATE']

    # Paths to search.
    attr_accessor :paths

    # Labels to document. Defaults are: TODO, FIXME, OPTIMIZE and DEPRECATE.
    attr_accessor :labels

    #
    def initialize(paths, labels=nil)
      @paths  = [paths  || DEFAULT_PATHS ].flatten
      @labels = [labels || DEFAULT_LABELS].flatten
      parse
    end

    #
    def notes
      @notes
    end

    #
    def counts
      @counts
    end

    #
    def each(&block)
      notes.each(&block)
    end

    #
    def empty?
      notes.empty?
    end

    #
    def labels=(labels)
      @labels = (
        case labels
        when String
          labels.split(/[:;,]/)
        else
          labels = [labels].flatten.compact.uniq.map{ |s| s.to_s }
        end
      )
    end

    # Gather and count notes. This returns two elements,
    # a hash in the form of label=>notes and a counts hash.

    def parse
      records, counts = [], Hash.new(0)
      files.each do |fname|
        next unless File.file?(fname)
        #next unless fname =~ /\.rb$/      # TODO: should this be done?
        File.open(fname) do |f|
          lineno, save, text = 0, nil, nil
          while line = f.gets
            lineno += 1
            save = match_common(line, lineno, fname) || match_arbitrary(line, lineno, fname)
            if save
              #file = fname
              text = save['note']
              #save = {'label'=>label,'file'=>file,'line'=>line_no,'note'=>text}
              records << save
              counts[save['label']] += 1
            else
              if text
                if line =~ /^\s*[#]{0,1}\s*$/ or line !~ /^\s*#/ or line =~ /^\s*#[+][+]/
                  text.strip!
                  text = nil
                else
                  if text[-1,1] == "\n"
                    text << line.gsub(/^\s*#\s*/,'')
                  else
                    text << "\n" << line.gsub(/^\s*#\s*/,'')
                  end
                end
              end
            end
          end
        end
      end
      # organize the notes
      notes = organize(records)
      #
      @notes, @counts = notes, counts
    end

    #
    def files
      @files ||= (
        [self.paths].flatten.map do |path|
          if File.directory?(path)
            Dir.glob(File.join(path, '**/*'))
          else
            Dir.glob(path)
          end
        end.flatten.uniq
      )
    end

    # TODO: ruby-1.9.1-p378 reports: notes.rb:131:in `match': invalid byte sequence in UTF-8 
    def match_common(line, lineno, file)
      rec = nil
      labels.each do |label|
        if md = /\#\s*#{Regexp.escape(label)}[:]?\s*(.*?)$/.match(line)
          text = md[1]
          rec = {'label'=>label,'file'=>file,'line'=>lineno,'note'=>text}
        end
      end
      return rec
    end

    #
    def match_arbitrary(line, lineno, file)
      rec = nil
      labels.each do |label|
        if md = /\#\s*([A-Z]+)[:]\s*(.*?)$/.match(line)
          label, text = md[1], md[2]
          rec = {'label'=>label,'file'=>file,'line'=>lineno,'note'=>text}
        end
      end
      return rec
    end

    # Organize records in heirarchical form.
    #
    def organize(records)
      orecs = {}
      records.each do |record|
        label = record['label']
        file  = record['file']
        line  = record['line']
        note  = record['note'].rstrip
        orecs[label] ||= {}
        orecs[label][file] ||= []
        orecs[label][file] << [line, note]
      end
      orecs
    end

    #
    def to(format)
      __send__("to_#{format}")
    end

    #
    def to_yaml
      require 'yaml'
      notes.to_yaml
    end

    #
    def to_json
      begin
        require 'json'
      rescue LoadError
        require 'json_pure'
      end
      notes.to_json
    end

    # Soap envelope XML.
    def to_soap
      require 'soap/marshal'
      SOAP::Marshal.marshal(notes)
    end

    # XOXO microformat.
    def to_xoxo
      require 'xoxo'
      notes.to_xoxo
    end

  end

end

