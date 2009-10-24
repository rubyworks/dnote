#!/usr/bin/env ruby

module DNote
  require 'optparse'
  require 'dnote'

  def self.run
    options = {}

    opts = OptionParser.new do |opt|

      opt.banner = "Usage: dnote [OPTIONS] path1 [path2 ...]"

      opt.separator(" ")
      opt.separator("OUTPUT FORMAT: (choose one)")

      opt.on("--rdoc", "RDoc comment format") do |format|
        options[:format] = 'rdoc'
      end

      opt.on("--markdown", "Markdown wiki format") do |format|
        options[:format] = 'markdown'
      end

      opt.on("--xml", "XML markup format") do |format|
        options[:format] = 'xml'
      end

      opt.on("--html", "HTML markup format") do |format|
        options[:format] = 'html'
      end

      opt.on("--yaml", "YAML serialization format") do |format|
        options[:format] = 'yaml'
      end

      opt.on("--json", "JSON serialization format") do |format|
        options[:format] = 'json'
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

      #opt.on("--output", "-o [FILE]", "name of file to store output (w/o extension)") do |out|
      #  options[:output] = out
      #end

      opt.separator(" ")
      opt.separator("STANDARD OPTIONS:")

      opt.on("--verbose", "-v", "extra verbose output") do
        options[:verbose] = true
      end

      opt.on("--debug", "debug mode") do
        $DEBUG = true
      end

      #opt.on("--quiet", "-q", "surpress non-essential output") do
      #  options[:quiet] = true
      #end

      #opt.on("--noharm", "-n", "only pretend to write to disk") do
      #  options[:noharm] = true
      #end

      #opt.on("--dryrun", "noharm and verbose modes combined") do
      #  options[:verbose] = true
      #  options[:noharm] = true
      #end

      #opt.on("--trace", "debug and verbose modes combined") do
      #  $DEBUG = true
      #  options[:verbose] = true
      #end

      opt.on_tail('--help', '-h', "show this help information") do
        puts opt
        exit
      end

    end

    opts.parse!

    paths = ARGV.dup
    dnote = DNote.new(paths, options)
    dnote.document
  end

end

