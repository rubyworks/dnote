module DNote

  require 'dnote/notes'
  require 'dnote/format'

  # User session which is used by commandline interface.
  #
  # By making this a class it makes it easy for external
  # libraries to use this library just as if they were
  # calling the commandline, but without the need to shellout.
  #
  class Session

    DIR = File.dirname(__FILE__)

    # Default format.
    DEFAULT_FORMAT = "label"

    # Default title.
    DEFAULT_TITLE = "Developer's Notes"

    # Paths to include.
    attr :paths

    # Paths to exclude (match by pathname).
    attr :exclude

    # Paths to ignore (match by basename).
    attr :ignore

    # Special labels that are looked for without a separating colon.
    # By default these are TODO, FIXME and OPTIMIZE.
    attr :labels

    # Output format.
    attr_accessor :format

    # If custom format, sepcify template file.
    attr_accessor :template

    # Some format put a title at the top of the output.
    # The default is "Developer's Notes".
    attr_accessor :title

    # Output to a file instead of STDOUT.
    attr_accessor :output

    #
    #attr_accessor :dryrun

    #
    def initialize(options={})
      @paths   = []
      @exclude = []
      @ignore  = []
      @format  = DEFAULT_FORMAT
      @title   = DEFAULT_TITLE
      options.each{ |k,v| __send__("#{k}=", v) }
      yield(self) if block_given?
    end

    # Run session.
    def run
      notes = Notes.new(files, labels)
      formatter = Format.new(notes) do |f|
        f.format   = format
        f.template = template
        f.title    = title
        f.output   = output
      end
      formatter.render
    end

    # Collect path globs and remove exclusions.
    def files
      list = ['**/*.rb'] if paths.empty?
      list = [list].flatten
      list = glob(list)
      list = list - glob(exclude)
      list.reject do |path|
        path.split('/').any?{ |part| ignore.any?{ |ig| File.fnmatch?(ig, part) } }
      end
    end

    # Collect the file glob of each path given. If 
    # a path is a directory, inclue all content.
    def glob(paths)
      paths.map do |path|
        if File.directory?(path)
          Dir.glob(File.join(path, '**/*'))
        else
          Dir.glob(path)
        end
      end.flatten.uniq
    end

    # Commandline interface.
    def self.main(*argv)
      require 'optparse'

      session = Session.new

      opts = OptionParser.new do |opt|

        opt.banner = "Usage: dnote [OPTIONS] path1 [path2 ...]"

        opt.separator(" ")
        opt.separator("OUTPUT FORMAT: (choose one)")

        #opt.on("--default", "Plain text format (default)") do
        #  session.format = 'label'
        #end

        opt.on("--file", "Plain text format by file") do
          session.format = 'file'
        end

        opt.on("--yaml", "YAML serialization format") do
          session.format = 'yaml'
        end

        opt.on("--json", "JSON serialization format") do
          session.format = 'json'
        end

        opt.on("--soap", "SOAP XML envelope format") do
          session.format = 'soap'
        end

        opt.on("--xoxo", "XOXO microformat format") do
          session.format = 'xoxo'
        end

        opt.on("--xml", "XML markup format") do
          session.format = 'xml'
        end

        opt.on("--html", "HTML markup format") do
          session.format = 'html'
        end

        opt.on("--rdoc", "RDoc comment format") do
          session.format = 'rdoc'
        end

        opt.on("--markdown", "Markdown wiki format") do
          session.format = 'markdown'
        end

        opt.on("--format", "-f NAME", "Select a alternate format") do |format|
          session.format = format
        end

        opt.on("--template", "-t FILE", "Use a custom Erb template") do |file|
          session.format = 'custom'
          session.template = file
        end

        opt.separator(" ")
        opt.separator("OTHER OPTIONS:")

        opt.on("--label", "-l LABEL", "labels to collect") do |lbl|
          session.labels << lbl
        end

        opt.on("--exclude", "-x PATH", "exclude file or directory") do |path|
          session.exclude << path
        end

        opt.on("--ignore", "-i NAME", "ignore based on any part of the pathname") do |name|
          session.ignore << name
        end

        opt.on("--title", "-T TITLE", "title to use in headers") do |title|
          session.title = title
        end

        opt.on("--output", "-o PATH", "name of file or directory") do |path|
          session.output = path
        end

        opt.separator(" ")
        opt.separator("STANDARD OPTIONS:")

        opt.on("--debug", "debug mode") do
          $DEBUG = true
        end

        opt.on("--dryrun", "-n", "do not actually write to disk") do
          session.dryrun = true
        end

        opt.on_tail('--list', "list all available templated formats") do
          list = Dir[File.join(DIR, 'templates', '*')].map{ |f| File.basename(f).chomp('.erb') }
          puts list.sort.join("\n")
          exit
        end

        opt.on_tail('--help', '-h', "show this help information") do
          puts opt
          exit
        end
      end

      begin
        opts.parse!(argv)
        session.paths.replace(argv)
        session.run
      rescue => err
        raise err if $DEBUG
        puts err
        exit 1
      end
    end

  end

end

