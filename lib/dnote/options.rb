# frozen_string_literal: true

require "dnote/core_ext"
require "dnote/notes"
require "dnote/format"
require "optparse"

module DNote
  # Option parser
  class Options
    def self.parse(*argv)
      new(argv).parse
    end

    def initialize(argv)
      @argv = argv
    end

    def parse
      session = Session.new

      opts = OptionParser.new do |opt|
        opt.banner = "DNote v#{DNote::VERSION}"

        opt.separator(" ")
        opt.separator("USAGE:\n  dnote [OPTIONS] path1 [path2 ...]")

        add_output_format_options(session, opt)
        add_other_options(session, opt)
        add_command_options(session, opt)
      end

      opts.parse!(@argv)
      session.paths.replace(@argv)
      session
    end

    def add_command_options(session, opt)
      opt.separator(" ")
      opt.separator("COMMAND OPTIONS:")

      opt.on_tail("--templates", "-T", "list available format templates") do
        session.list_templates
        exit
      end

      opt.on_tail("--help", "-h", "show this help information") do
        puts opt
        exit
      end
    end

    def add_output_format_options(session, opt)
      opt.separator(" ")
      opt.separator("OUTPUT FORMAT: (choose one)")

      opt.on("--format", "-f NAME", "select a format [text]") do |format|
        session.format = format
      end

      opt.on("--custom", "-C FILE", "use a custom ERB template") do |file|
        session.format = "custom"
        session.template = file
      end

      opt.on("--file", "shortcut for text/file format") do
        session.format = "text/file"
      end

      opt.on("--list", "shortcut for text/list format") do
        session.format = "text/list"
      end
    end

    def add_other_options(session, opt)
      opt.separator(" ")
      opt.separator("OTHER OPTIONS:")

      opt.on("--label", "-l LABEL", "labels to collect") do |lbl|
        session.labels.concat(lbl.split(":"))
      end

      opt.on(:colon, "--[no-]colon", "match labels with/without colon suffix") do |val|
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
    end
  end
end
