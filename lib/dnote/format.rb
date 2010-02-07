module DNote

  # = Notes Formatter
  #
  #--
  #   TODO: Need good CSS file.
  #
  #   TODO: Need XSL?
  #++
  class Format

    require 'fileutils'
    require 'erb'
    require 'rexml/text'

    #DEFAULT_OUTPUT_DIR = "log/dnote"

    EXTENSIONS = { 'soap'=>'xml', 'xoxo'=>'xml' }

    #
    attr :notes

    #
    attr_accessor :format

    #
    attr_accessor :output

    #
    attr_accessor :template

    #
    attr_accessor :title

    #
    attr_accessor :dryrun

    #
    def initialize(notes, options={})
      @notes  = notes
      @format = :gnu
      @title  = "Developer's Notes"
      options.each do |k,v|
        __send__("#{k}=", v) if v
      end
    end

    #
    def render
      if notes.empty?
        $stderr << "No #{notes.labels.join(', ')} notes.\n"
      else
        raise ArgumentError unless respond_to?("render_#{format}")
        __send__("render_#{format}")
      end
    end

    # S E R I A L I Z A T I O N

    def render_yaml
      result = notes.to_yaml
      publish(result)
    end

    def render_json
      result = notes.to_json
      publish(result)
    end

    # M L  M A R K U P

    def render_soap
      result = notes.to_soap
      publish(result)
    end

    def render_xoxo
      result = notes.to_xoxo
      publish(result)
    end

    def render_xml
      template = File.join(File.dirname(__FILE__), 'templates/xml.erb')
      result = erb(template)
      publish(result)
    end

    def render_html
      template = File.join(File.dirname(__FILE__), 'templates/html.erb')
      result = erb(template)
      publish(result)
    end

    def render_index
      template = File.join(File.dirname(__FILE__), 'templates/html.erb')
      result = erb(template)
      publish(result, 'index.html')
    end

    # W I K I  M A R K U P

    def render_gnu
      template = File.join(File.dirname(__FILE__), 'templates/gnu.erb')
      result = erb(template)
      publish(result)
    end

    def render_rdoc
      template = File.join(File.dirname(__FILE__), 'templates/rdoc.erb')
      result = erb(template)
      publish(result)
    end

    def render_markdown
      template = File.join(File.dirname(__FILE__), 'templates/markdown.erb')
      result = erb(template)
      publish(result)
    end

    # C U S T O M  T E M P L A T E

    def render_custom
      result = erb(template)
      publish(result)    
    end

  private

    #
    def erb(file)
      scope = ErbScope.new(:notes=>notes, :title=>title)
      scope.render(file)
    end

    #
    def publish(result, fname=nil)
      if output
        write(result, fname)
      else
        puts(result)
      end
      $stderr << "(" + notes.counts.map{|l,n| "#{n} #{l}s"}.join(', ') + ")\n"
    end

    #
    def write(result, fname=nil)
      if output.end_with?('/') || File.directory?(output)
        ext  = EXTENSIONS[format] || format
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
        File.open(file, 'w'){ |f| f << result }
      end
      return file
    end

    #
    def dryrun?
      @dryrun
    end

    #
    def debug?
      $DEBUG
    end

    #
    def fu
      @fu ||= (
        if dryrun? and debug?
          FileUtils::DryRun
        elsif dryrun?
          FileUtils::Noop
        elsif debug?
          FileUtils::Verbose
        else
          FileUtils
        end
      )
    end

    #
    class ErbScope 
      #
      def initialize(data={})
        @data = data
      end
      #
      def render(file)
        erb = ERB.new(File.read(file), nil, '<>')
        erb.result(binding)
      end
      #
      def h(string)
        REXML::Text.normalize(string)
      end
      #
      def method_missing(s, *a)
        @data[s.to_sym]
      end
    end

  end

end

