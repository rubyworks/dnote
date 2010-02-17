module DNote

  require 'dnote/notes'

  # Site class is used to build a "pretty" output set.
  # The template files are saved to the +output+ directory.
  # Additional +formats+ can be saved to the directory
  # as well.

  class Site

    # Default output directory is +log/dnote/+.
    DEFAULT_OUTPUT = Pathname.new('log/dnote')

    # Title to use in any headers.
    attr_accessor :title

    # Directory to save output.
    attr_accessor :output

    # Additional Formats to supply besides the html (xml, rdoc, markdown, etc.)
    attr_accessor :formats

    # Notes object.
    attr_reader :notes

    def initialize(paths, options)
      initialize_defaults

      self.title   = options[:title]          if options[:title]

      self.output  = options.delete(:output)  if options[:output]
      self.formats = options.delete(:formats) if options[:formats]

      @notes = Notes.new(paths, options)
    end

    #
    def initialize_defaults
      @output   = DEFAULT_OUTPUT
      @title    = "Development Notes"
      @formats  = ['html']
    end

    #
    def output=(path)
      raise "output cannot be root" if File.expand_path(path) == "/"
      @output = Pathname.new(path)
    end

    #
    def document
      fu.mkdir_p(output)

      # produce requested additional formats
      formats.each do |format|
=begin
        tdir = tempdir(format)

        # copy non-erb files
        files = Dir.entries(tdir) - ['.', '..']
        files = files.reject{ |file| File.extname(file) == '.erb' }
        files.each do |file|
          dest = File.dirname(file).sub(tdir, '')
          fu.cp_r(File.join(tdir, file), output)
        end

        # write the erb templates
        templates(format).each do |temp|
          file = File.join(tdir, temp)
          erb  = ERB.new(File.read(file))
          text = erb.result(binding)
          write(temp.chomp('.erb'), text)
        end
=end
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
    tempdir(format)
      "#{__DIR__}/templates/#{format}"
    end

    # TODO: Don't use chdir.
    def templates(format)
      temps = []
      Dir.chdir(tempdir(format)) do
        temps = Dir['**/*.erb']
      end
      temps
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
