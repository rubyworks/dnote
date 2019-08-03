# frozen_string_literal: true

require 'dnote/core_ext'
require 'dnote/notes'
require 'dnote/format'
require 'dnote/options'

module DNote
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
    DEFAULT_FORMAT = 'text'

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
    def initialize(options = {})
      options ||= {}
      initialize_defaults
      options.each { |k, v| __send__("#{k}=", v) }
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
      @exclude = [list].compact.flatten.compact
    end

    # Set ignore list ensuring that the value is an array.
    def ignore=(list)
      @ignore = [list].compact.flatten.compact
    end

    # Run session.
    def run
      notes = Notes.new(files,
                        labels: labels,
                        colon: colon,
                        marker: marker,
                        url: url,
                        context: context)
      collection = notes.notes_collection
      formatter = Format.new(collection,
                             format: format,
                             template: template,
                             title: title,
                             output: output)
      formatter.render
    end

    # Collect path globs and remove exclusions.
    # This method uses #paths, #exclude and #ignore to
    # compile the list of files.
    def files
      list = [paths].flatten.compact
      list = ['**/*.rb'] if list.empty?
      list = glob(list)
      list -= glob(exclude)
      list.reject do |path|
        path.split('/').any? { |part| ignore.any? { |ig| File.fnmatch?(ig, part) } }
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
      session = Options.parse(*argv)
      session.run
    end
  end
end
