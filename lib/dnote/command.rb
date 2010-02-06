#!/usr/bin/env ruby

module DNote
  require 'optparse'
  require 'dnote'
  require 'dnote/format'

  def self.run
    options = {}
    format  = 'rdoc'

    opts = OptionParser.new do |opt|

      opt.banner = "Usage: dnote [OPTIONS] path1 [path2 ...]"

      opt.separator(" ")
      opt.separator("OUTPUT FORMAT: (choose one)")

      opt.on("--gnu", "Plain text format (default)") do
        options[:format] = 'gnu'
      end

      opt.on("--rdoc", "RDoc comment format") do
        options[:format] = 'rdoc'
      end

      opt.on("--markdown", "Markdown wiki format") do
        options[:format] = 'markdown'
      end

      opt.on("--soap", "SOAP XML envelope format") do
        options[:format] = 'soap'
      end

      opt.on("--xoxo", "XOXO microformat format") do
        options[:format] = 'xoxo'
      end

      opt.on("--xml", "XML markup format") do
        options[:format] = 'xml'
      end

      opt.on("--html", "HTML markup format") do
        options[:format] = 'html'
      end

      opt.on("--yaml", "YAML serialization format") do
        options[:format] = 'yaml'
      end

      opt.on("--json", "JSON serialization format") do
        options[:format] = 'json'
      end

      opt.on("--template", "-t FILE", "Use a custom Erb template") do |file|
        options[:format] = 'custom'
        options[:template] = file
      end

      opt.separator(" ")
      opt.separator("OTHER OPTIONS:")

      opt.on("--label", "labels to collect") do |lbl|
        options[:labels] ||= []
        options[:labels] << lbl
      end

      opt.on("--title", "-t [TITLE]", "title to use in headers") do |title|
        options[:title] = title
      end

      opt.on("--output", "-o [PATH]", "name of file (w/o extension) or directory") do |path|
        options[:output] = path
      end

      opt.separator(" ")
      opt.separator("STANDARD OPTIONS:")

      #opt.on("--verbose", "-v", "extra verbose output") do
      #  options[:verbose] = true
      #end

      opt.on("--debug", "debug mode") do
        $DEBUG = true
      end

      #opt.on("--quiet", "-q", "surpress non-essential output") do
      #  options[:quiet] = true
      #end

      #opt.on("--noharm", "-n", "only pretend to write to disk") do
      #  options[:noharm] = true
      #end

      opt.on("--dryrun", "-n", "do not actually write to disk") do
        options[:dryrun] = true
      end

      #opt.on("--trace", "debug and verbose modes combined") do
      #  $DEBUG = true
      #  options[:verbose] = true
      #end

      opt.on_tail('--help', '-h', "show this help information") do
        puts opt
        exit
      end

    end

    begin
      opts.parse!
    rescue => err
      puts err
      exit 1
    end

    paths = ARGV.dup
    paths = ['**/*.rb'] if paths.empty?

    notes  = Notes.new(paths, options[:labels])
    format = Format.new(notes, options)
    format.render

    # NOTE: If DNote were a class.

    #if output
    #  dnote.save(format, output)
    #else
    #  dnote.display(format)
    #end
  end

end

