module DNote
  # = Developmer's Notes Rake Task
  #
  class RakeTask < Rake::TaskLib
    require 'rake/clean'

    # Default note labels to looked for in source code.
    DEFAULT_LABELS = %w(TODO FIXME OPTIMIZE DEPRECATE).freeze

    # File paths to search.
    attr_accessor :files

    # Labels to document. Defaults are: TODO, FIXME, OPTIMIZE and DEPRECATE.
    attr_accessor :labels

    # Formats (xml, html, rdoc, rdoc/list and so on).
    attr_accessor :formats

    # Exclude paths.
    attr_accessor :exclude

    # Ignore paths based on any part of pathname.
    attr_accessor :ignore

    # Output directory to save notes file. Defaults to <tt>dnote/</tt> under
    # the project log directory (eg. <tt>log/dnote/</tt>).
    attr_reader :output

    # Title to use if temaplte can use it.
    attr_accessor :title

    #
    def output=(path)
      @output = Pathname.new(path)
    end

    #
    def init
      require 'dnote'
      require 'dnote/format'
      @files   = '**/*.rb'
      @output  = 'log/dnote'
      @formats = ['index']
      @labels  = nil
    end

    #
    def define
      desc "Collect Developer's Notes"
      task 'dnote' do
        document
      end
      task 'dnote:clobber' do
        clean
      end
      task clobber: ['dnote:clobber']
    end

    # Generate notes document(s).
    def document
      abort "dnote: #{output} is not a directory" unless output.directory?

      session = ::DNote::Session.new do |s|
        s.paths   = files
        s.exclude = exclude
        s.ignore  = ignore
        s.labels  = labels
        s.title   = title
        s.output  = output
        s.dryrun  = application.options.dryrun # trial?
      end

      formats.each do |format|
        if format == 'index'
          session.format = 'html'
          session.output = File.join(output, 'index.html')
        else
          session.format = format
        end
        session.run
        report "Updated #{output.to_s.sub(Dir.pwd + '/', '')}" unless trial?
      end
    end

    # Remove output files.
    def clean
      formats.each do |format|
        if format == 'index'
          file = (output + 'index.html').to_s
        else
          ext = ::DNote::Format::EXTENSIONS[format] || format
          file = (output + "notes.#{ext}").to_s
        end
        rm(file)
        report "Removed #{output}"
      end
    end
  end
end
