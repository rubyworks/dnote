module DNote

  require 'dnote/core_ext'
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
    attr_reader :exclude

    # Paths to ignore (match by basename).
    attr_reader :ignore

    # Labels to lookup.
    # By default these are TODO, FIXME and OPTIMIZE.
    attr_accessor :labels

    # Selected labels can optionally do without the colon.
    attr_accessor :colon

    # Alternate remark marker. Useful to other languages besides Ruby.
    attr_accessor :marker

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

    # String template for line URLs (mainly for HTML format). For example,
    # DNote uses GitHub so we could use a link template:
    # 
    #   "https://github.com/rubyworks/dnote/blob/master/%s#L%s"
    #
    attr_accessor :url

    # Number of lines of context to display. The default is zero.
    attr_accessor :context

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
      @marker  = nil
      @url     = nil
      @context = 0
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
      notes = Notes.new(files, :labels=>labels, :colon=>colon, :marker=>marker, :url=>url, :context=>context)
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

        opt.on("--format", "-f NAME", "select a format [text]") do |format|
          session.format = format
        end

        opt.on("--custom", "-C FILE", "use a custom ERB template") do |file|
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

        opt.on("--marker", "-m MARK", "alternative remark marker") do |mark|
           session.marker = mark 
        end

        opt.on("--url", "-u TEMPLATE", "url template for line entries (for HTML)") do |url|
           session.url = url
        end

        opt.on("--context", "-c INTEGER", "number of lines of context to display") do |int|
           session.context = int.to_i
        end

        opt.on("--exclude", "-x PATH", "exclude file or directory") do |path|
          session.exclude << path
        end

        opt.on("--ignore", "-i NAME", "ignore file based on any part of pathname") do |name|
          session.ignore << name
        end

        opt.on("--title", "-t TITLE", "title to use in header") do |title|
          session.title = title
        end

        opt.on("--output", "-o PATH", "save to file or directory") do |path|
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
            puts("%-18s " * names.size % names.sort)
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

