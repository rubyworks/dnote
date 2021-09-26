# frozen_string_literal: true

module DNote
  # = Notes Formatter
  #
  #--
  #   TODO: Need good CSS file.
  #
  #   TODO: Need XSL?
  #++
  class Format
    require "fileutils"
    require "erb"
    require "rexml/text"
    require "dnote/core_ext"

    EXTENSIONS = { "text" => "txt", "soap" => "xml", "xoxo" => "xml" }.freeze

    attr_reader :notes, :format, :output, :template, :title, :dryrun

    def initialize(notes,
                   format: "text",
                   title: "Developer's Notes",
                   template: nil,
                   output: nil,
                   dryrun: false)
      @notes    = notes
      @format   = format
      @title    = title
      @dryrun   = dryrun
      @template = template
      @output   = output
    end

    def render
      if notes.empty?
        $stderr << "No #{notes.labels.join(', ')} notes.\n"
      else
        case format
        when "custom"
          render_custom
        else
          render_template
        end
      end
    end

    private

    # C U S T O M

    def render_custom
      result = erb(template)
      publish(result)
    end

    # T E M P L A T E

    def render_template
      template = File.join(File.dirname(__FILE__), "templates", "#{format}.erb")
      raise "No such format - #{format}" unless File.exist?(template)

      result = erb(template)
      publish(result)
    end

    def erb(file)
      scope = ErbScope.new(notes: notes, title: title)
      scope.render(file)
    end

    def publish(result, fname = nil)
      if output
        write(result, fname)
      else
        puts(result)
      end
      $stderr << "(#{notes.counts.map { |l, n| "#{n} #{l}s" }.join(', ')})\n"
    end

    def write(result, fname = nil)
      if output.to_s[-1, 1] == "/" || File.directory?(output)
        fmt  = format.split("/").first
        ext  = EXTENSIONS[fmt] || fmt
        file = File.join(output, fname || "notes.#{ext}")
      else
        file = output
      end
      if dryrun?
        puts "mkdir: #{File.dirname(file)}"
        puts "write: #{file}"
      else
        dir = File.dirname(file)
        fu.mkdir(dir) unless File.exist?(dir)
        File.open(file, "w") { |f| f << result }
      end
      file
    end

    def dryrun?
      @dryrun
    end

    def debug?
      $DEBUG
    end

    def fu
      @fu ||=
        if dryrun? && debug?
          FileUtils::DryRun
        elsif dryrun?
          FileUtils::Noop
        elsif debug?
          FileUtils::Verbose
        else
          FileUtils
        end
    end

    # Evaluation scope for ERB templates
    class ErbScope
      def initialize(data = {})
        @data = data
      end

      def render(file)
        contents = File.read(file)
        erb = ERB.new(contents, trim_mode: "<>")
        erb.result(binding)
      end

      def h(string)
        REXML::Text.normalize(string)
      end

      def method_missing(method, *_args)
        sym = method.to_sym
        return @data.fetch(sym) if @data.key? sym

        super
      end

      def respond_to_missing?(method)
        @data.key?(method.to_sym) || super
      end
    end
  end
end
