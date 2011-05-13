module Syckle::Plugins

  # = Developmer's Notes Plugin
  #
  # This plugin goes through you source files and compiles
  # an lit of any labeled comments. Labels are single word
  # prefixes to a comment ending in a colon. For example,
  # you might note somewhere in your code:
  #
  # By default this label supports the TODO, FIXME, OPTIMIZE
  # and DEPRECATE.
  #
  # Output is a set of files in HTML, XML and RDoc's simple
  # markup format. This plugin can run automatically if there
  # is a +notes/+ directory in the project's log directory.
  #
  #--
  # TODO: Should this service be part of the +site+ cycle?
  #++
  class DNote < Service

    cycle :main, :document
    cycle :main, :reset
    cycle :main, :clean

    # not that this is necessary, but ...
    #available do |project|
    #  begin
    #    require 'dnote'
    #    require 'dnote/format'
    #    true
    #  rescue LoadError
    #    false
    #  end
    #end

    ## autorun if log/notes exists
    #autorun do |project|
    #  (project.log + 'dnote').exist?
    #end

    # Default note labels to looked for in source code.
    DEFAULT_LABELS = ['TODO', 'FIXME', 'OPTIMIZE', 'DEPRECATE']

    # File paths to search.
    attr_accessor :files

    # Labels to document. Defaults are: TODO, FIXME, OPTIMIZE and DEPRECATE.
    attr_accessor :labels

    # Exclude paths.
    attr_accessor :exclude

    # Ignore paths based on any part of pathname.
    attr_accessor :ignore

    # Output directory to save notes file. Defaults to <tt>dnote/</tt> under
    # the project log directory (eg. <tt>log/dnote/</tt>).
    attr_reader :output

    # Formats (xml, html, rdoc).
    attr_accessor :formats

    # Title to use if temaplte can use it.
    attr_accessor :title

    #
    def output=(path)
      @output = Pathname.new(path)
    end

    #
    #def dnote
    #  @dnote ||= ::DNote::Site.new(files, :labels=>labels, :formats=>formats, :output=>output)
    #end

    # Generate notes documents.
    #--
    # TODO: Is #trial? correct?
    #++
    def document
      session = ::DNote::Session.new do |s|
        s.paths   = files
        s.exclude = exclude
        s.ignore  = ignore
        s.labels  = labels #|| DEFAULT_LABELS   
        s.title   = title
        s.output  = output
        s.dryrun  = trial?
      end
      formats.each do |format|
        if format == 'index'
          session.format = 'html'
          session.output = File.join(self.output, 'index.html')
        else
          session.format = format
        end
        session.run
        report "Updated #{output.to_s.sub(Dir.pwd+'/','')}" unless trial?
      end

      #files = files.map{ |f| Dir[f] }.flatten
      #notes = ::DNote::Notes.new(files, :labels=>labels)
      #[formats].flatten.each do |format|
      #  if format == 'index'
      #    format = 'html'
      #    output = File.join(self.output, 'index.html')
      #  end
      #  format = ::DNote::Format.new(notes, :format=>format, :output=>output.to_s, :title=>title, :dryrun=>trial?)
      #  format.render
      #  report "Updated #{output.to_s.sub(Dir.pwd+'/','')}" unless trial?
      #end
    end

    # Reset output directory, marking it as out-of-date.
    def reset
      if File.directory?(output)
        File.utime(0,0,output) unless $NOOP
        puts "Marked #{output}"
      end
    end

    # Remove output files.
    def clean
      if File.directory?(output)
        formats.each do |format|
          ext = ::DNote::Format::EXTENSIONS[format] || format
          file = (output + "notes.#{ext}").to_s
          rm(file)
          report "Removed #{output}"
        end
      end
    end

  private

    #
    def initialize_requires
      require 'dnote'
      require 'dnote/format'
    end

    #
    def initialize_defaults
      @files   = "**/*.rb"
      @output  = project.log + 'dnote'
      @formats = ['index']
      @labels  = nil #DEFAULT_LABELS
    end

  end

end

