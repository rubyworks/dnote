module DNote

  require 'dnote/notes'

  # Site class is used to build a "pretty" output set.
  # The template files are saved to the +output+ directory.
  # Additional +formats+ can be saved the the directory
  # as well.

  class Site

    # Default output directory is +dnote/+.
    DEFAULT_OUTPUT = Pathname.new('dnote')

    # Title to use in any headers.
    attr_accessor :title

    # Directory to save output.
    attr_accessor :output

    # Additional Formats to supply besided the html (xml, rdoc, markdown, etc.)
    attr_accessor :formats

    # Notes object.
    attr_reader :notes

    def initialize(paths, options)
      self.title   = options[:title]

      self.output  = options.delete(:output)
      self.formats = options.delete(:formats)

      @notes = Notes.new(paths, options)
    end

    #
    def initialize_defaults
      @output   = DEFAULT_OUTPUT
      @title    = "Development Notes"
      @formats  = []
    end

    #
    def output=(path)
      raise "output cannot be root" if File.expand_path(path) == "/"
      @output = Pathname.new(path)
    end

    #
    def document
      fu.mkdir_p(output)

      # copy the whole template directory over
      fu.cp_r("#{__DIR__}/template/", "#{output}/")

      # (re)write the erb templates
      templates.each do |temp|
        erb  = ERB.new(File.read(temp))
        text = erb.result(binding)
        file = File.basename(temp)
        write(file, text)
      end

      # produce requested additional formats
      formats.each do |format|
        text = notes.to(format)
        write("notes.#{format}", text)
      end
    end

    # Reset output directory, marking it as out-of-date.
    def reset
      if File.directory?(output)
        File.utime(0,0,output) unless $NOOP
        puts "marked #{output}"
      end
    end

    # Remove output directory.
    def clean
      if File.directory?(output)
        fu.rm_r(output)
        puts "removed #{output}"
      end
    end

    #
    def templates
      @templates ||= (
        Dir[File.join(File.dirname(__FILE__), 'template/*')].select{ |f| File.file?(f) }
      )
    end

    # Save file to output.
    #
    def write(fname, text)
      file = output + fname
      fu.mkdir_p(file.parent)
      File.open(file, 'w') { |f| f << text } unless $NOOP
    end

    def __DIR__
      File.dirname(__FILE__)
    end

    #
    def fu
      @fu ||= (
        if $NOOP and $DEBUG
          FileUtils::DryRun
        elsif $NOOP
          FileUtils::Noop
        elsif $DEBUG
          FileUtils::Verbose
        else
          FileUtils
        end
      )
    end

  end

 end
