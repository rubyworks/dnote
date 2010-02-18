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

    # Directory relative to this script. This is used
    # to lookup the available format templates.
    DIR = File.dirname(__FILE__)

    # Default format.
    DEFAULT_FORMAT  = "text"

    # Default title.
    DEFAULT_TITLE = "Developer's Notes"

    # Paths to include.
    attr_accessor :paths

    # Paths to exclude (match by pathname).
    attr_accessor :exclude

    # Paths to ignore (match by basename).
    attr_accessor :ignore

    # Labels to lookup.
    # By default these are TODO, FIXME and OPTIMIZE.
    attr_accessor :labels

    # Selected labels can optionally do without the colon.
    attr_accessor :colon

    # Output format.
    attr_accessor :format

    # If custom format, specify template file.
    attr_accessor :template

    # Some format put a title at the top of the output.
    # The default is "Developer's Notes".
    attr_accessor :title

    # Output to a file instead of STDOUT.
    attr_accessor :output

    # If output path given, don't actually write to disk.
    attr_accessor :dryrun

  private

    # New Session.
    def initialize(options={})
      options ||= {}
      initialize_defaults
      options.each{ |k,v| __send__("#{k}=", v) }
      yield(self) if block_given?
    end

    # Set default values for attributes.
    def initialize_defaults
      @paths   = []
      @labels  = []
      @exclude = []
      @ignore  = []
      @format  = DEFAULT_FORMAT
      @title   = DEFAULT_TITLE
      @dryrun  = false
    end

  public

    # Set exclude list ensuring that the value is an array.
    def exclude=(list)
      @exclude = [list].flatten.compact
    end

    # Set ignore list ensuring that the value is an array.
    def ignore=(list)
      @ignore = [list].flatten.compact
    end

    # Run session.
    def run
      notes = Notes.new(files, :labels=>labels, :colon=>colon)
      formatter = Format.new(notes) do |f|
        f.format   = format
        f.template = template
        f.title    = title
        f.output   = output
      end
      formatter.render
    end

    # Collect path globs and remove exclusions.
    # This method uses #paths, #exclude and #ignore to
    # compile the list of files.
    def files
      list = [paths].flatten.compact
      list = ['**/*.rb'] if list.empty?
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

    # Set special labels.
    #def labels=(labels)
    #  @labels = (
    #    case labels
    #    when String
    #      labels.split(/[:;,]/)
    #    else
    #      labels = [labels].flatten.compact.uniq.map{ |s| s.to_s }
    #    end
    #  )
    #end

    # Commandline interface.
    def self.main(*argv)
      require 'optparse'

      session = Session.new

      opts = OptionParser.new do |opt|

        opt.banner = "DNote v#{DNote::VERSION}"

        opt.separator(" ")
        opt.separator("USAGE:\n  dnote [OPTIONS] path1 [path2 ...]")

        opt.separator(" ")
        opt.separator("OUTPUT FORMAT: (choose one)")

        #opt.on("--default", "Plain text format (default)") do
        #  session.format = 'label'
        #end

        #opt.on("--yaml", "YAML serialization format") do
        #  session.format = 'yaml'
        #end

        #opt.on("--json", "JSON serialization format") do
        #  session.format = 'json'
        #end

        #opt.on("--soap", "SOAP XML envelope format") do
        #  session.format = 'soap'
        #end

        #opt.on("--xoxo", "XOXO microformat format") do
        #  session.format = 'xoxo'
        #end

        #opt.on("--xml", "XML markup format") do
        #  session.format = 'xml'
        #end

        #opt.on("--html", "HTML markup format") do
        #  session.format = 'html'
        #end

        #opt.on("--rdoc", "rdoc comment format") do
        #  session.format = 'rdoc'
        #end

        #opt.on("--markdown", "markdown wiki format") do
        #  session.format = 'md'
        #end

        opt.on("--format", "-f NAME", "select a format [text]") do |format|
          session.format = format
        end

        opt.on("--custom", "-c FILE", "use a custom ERB template") do |file|
          session.format = 'custom'
          session.template = file
        end

        opt.on("--file", "shortcut for text/file format") do
          session.format = 'text/file'
        end

        opt.on("--list", "shortcut for text/list format") do
          session.format = 'text/list'
        end

        opt.separator(" ")
        opt.separator("OTHER OPTIONS:")

        opt.on("--label", "-l LABEL", "labels to collect") do |lbl|
          session.labels.concat(lbl.split(':'))
        end

        opt.on("--[no-]colon", "match labels with/without colon suffix") do |val|
          session.colon = val
        end

        opt.on("--exclude", "-x PATH", "exclude file or directory") do |path|
          session.exclude << path
        end

        opt.on("--ignore", "-i NAME", "ignore based on any part of the pathname") do |name|
          session.ignore << name
        end

        opt.on("--title", "-t TITLE", "title to use in header") do |title|
          session.title = title
        end

        opt.on("--output", "-o PATH", "name of file or directory") do |path|
          session.output = path
        end

        opt.on("--dryrun", "-n", "do not actually write to disk") do
          session.dryrun = true
        end

        opt.on("--debug", "debug mode") do
          $DEBUG = true
          $VERBOSE = true
        end

        opt.separator(" ")
        opt.separator("COMMAND OPTIONS:")

        opt.on_tail('--templates', "-T", "list available format templates") do
          tdir   = File.join(DIR, 'templates')
          tfiles = Dir[File.join(tdir, '**/*.erb')]
          tnames = tfiles.map{ |tname| tname.sub(tdir+'/', '').chomp('.erb') }
          groups = tnames.group_by{ |tname| tname.split('/').first }
          groups.sort.each do |(type, names)|
            puts ("%-18s " * names.size) % names.sort
          end
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

