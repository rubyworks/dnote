require 'rexml/text'
require 'pathname'
require 'erb'
#require 'reap/project/scm'

module DNote

  # = Developer Notes
  #
  # This class goes through you source files and compiles
  # an list of any labeled comments. Labels are single word
  # prefixes to a comment ending in a colon.
  #
  # By default the labels supported are TODO, FIXME, OPTIMIZE and DEPRECATE.
  #
  # Output is a set of files in XML and RDoc's simple
  # markup format.
  #
  #   TODO: Add ability to read header notes. They oftern
  #         have a outline format, rather then the single line.
  #
  #   TODO: Need good CSS file.
  #
  #   TODO: Need XSL?
  #
  class Notes

    # Default note labels to look for in source code.
    DEFAULT_LABELS = ['TODO', 'FIXME', 'OPTIMIZE', 'DEPRECATE']

    #
    #DEFAULT_OUTPUT = Pathname.new('log/notes')

    #
    attr_accessor :title

    # Non-Operative
    #attr_accessor :noharm

    # Verbose
    attr_accessor :verbose

    # Paths to search.
    attr_accessor :paths

    # Labels to document. Defaults are: TODO, FIXME, OPTIMIZE and DEPRECATE.
    attr_accessor :labels

    # Directory or file to save output.
    # Defaults is current working directory.
    #attr_accessor :output

    # Format (xml, html, text).
    #attr_accessor :format

    #
    def initialize(paths, options={})
      initialize_defaults

      if paths.empty?
        #if file = File.exist?('meta/loadpath')
        #  paths = YAML.load(File.new(file)).to_list
        #  paths = Array === paths ? paths : paths.split(/\s+/)
        #elsif file = File.exist?('lib')
        #  paths = ['lib']
        #else
          paths = ['**/*.rb']
        #end
      end

      @paths = paths

      options.each do |k, v|
        __send__("#{k}=", v)
      end

      parse
    end

    #
    def initialize_defaults
      @paths    = ["lib"]
      #@output   = DEFAULT_OUTPUT
      @labels   = DEFAULT_LABELS
      @title    = "Developer's Notes"
      @format   = "rdoc"
    end

    #
    def noharm?  ; @noharm  ; end

    #
    def verbose? ; @verbose ; end

    #
    def notes
      @notes
    end

    #
    def counts
      @counts
    end

    #
    #def templates
    #  @templates ||= Dir[File.join(File.dirname(__FILE__), 'template/*')]
    #end

    # Scans source code for developer notes and writes them to 
    # well organized files.
    #
    def display(format)
      #paths    = self.paths
      #output   = self.output

      #parse

      #paths  = paths.to_list

      #labels = labels.split(',') if String === labels
      #labels = [labels].flatten.compact

      #records, counts = extract(labels, loadpath)
      #records = organize(records)

      #case format.to_s
      #when 'rdoc', 'txt', 'text'
      #  text = format_rd(records)
      #else
      #  text = format_xml(records)
      #end

      if notes.empty?
        $stderr << "No #{labels.join(', ')} notes.\n"
      else
        #temp = templates.find{ |f| /#{format}$/ =~ f }
        #erb  = ERB.new(File.read(temp))
        #text = erb.result(binding)

        text = __send__("to_#{format}")

        #if output
        #  #templates.each do |template|
        #    #text = format_notes(notes, format)
        #    file = write(txt, format)
        #    #file = file #Pathname.new(file).relative_path_from(Pathname.pwd) #project.root
        #    puts "Updated #{file}"
        #  #end
        #else
          puts text
        #end
        $stderr << "\n(" + counts.map{|l,n| "#{n} #{l}s"}.join(', ') + ")\n"
      end
    end

    # Reset output directory, marking it as out-of-date.
    #def reset
    #  if File.directory?(output)
    #    File.utime(0,0,output)
    #    puts "marked #{output}"
    #  end
    #end

    # Remove output directory.
    #def clean
    #  if File.directory?(output)
    #    fu.rm_r(output)
    #    puts "removed #{output}"
    #  end
    #end

    #
    def labels=(labels)
      @labels = (
        case labels
        when String
          labels.split(/[:;,]/)
        else
          labels = [labels].flatten.compact.uniq
        end
      )
    end

    #
    #def output=(path)
    #  raise "output cannot be root" if File.expand_path(output) == "/"
    #  @output = Pathname.new(output)
    #end

    # Gather and count notes. This returns two elements,
    # a hash in the form of label=>notes and a counts hash.

    def parse
      #
      files = self.paths.map do |path|
        if File.directory?(path)
          Dir.glob(File.join(path, '**/*'))
        else
          Dir.glob(path)
        end
      end.flatten.uniq

      #
      records, counts = [], Hash.new(0)

      # iterate through files extracting notes
      files.each do |fname|
        next unless File.file?(fname)
        #next unless fname =~ /\.rb$/      # TODO should this be done?
        File.open(fname) do |f|
          line_no, save, text = 0, nil, nil
          while line = f.gets
            line_no += 1
            labels.each do |label|
              if line =~ /^\s*#\s*#{Regexp.escape(label)}[:]?\s*(.*?)$/
                file = fname
                text = ''
                save = {'label'=>label,'file'=>file,'line'=>line_no,'note'=>text}
                records << save
                counts[label] += 1
              end
            end
            if text
              if line =~ /^\s*[#]{0,1}\s*$/ or line !~ /^\s*#/ or line =~ /^\s*#[+][+]/
                text.strip!
                text = nil
                #records << save
              else
                text << line.gsub(/^\s*#\s*/,'')
              end
            end
          end
        end
      end
      # organize the notes
      notes = organize(records)
      #
      @notes, @counts = notes, counts
    end

    # Organize records in heirarchical form.
    #
    def organize(records)
      orecs = {}
      records.each do |record|
        label = record['label']
        file  = record['file']
        line  = record['line']
        note  = record['note'].rstrip
        orecs[label] ||= {}
        orecs[label][file] ||= []
        orecs[label][file] << [line, note]
      end
      orecs
    end

    #
    #def format_notes(notes, type=:rdoc)
    #  send("format_#{type}", notes)
    #end

    # Format notes in RDoc format.
    #
    def to_rdoc
      out = []
      out << "= Development Notes"
      notes.each do |label, per_file|
        out << %[\n== #{label}]
        per_file.each do |file, line_notes|
          out << %[\n=== file://#{file}\n]
          line_notes.sort!{ |a,b| a[0] <=> b[0] }
          line_notes.each do |line, note|
            out << %[* #{note} (#{line})]
          end
        end
      end
      return out.join("\n")
    end

    # Format notes in RDoc format.
    #
    def to_markdown
      out = []
      out << "# Development Notes"
      notes.each do |label, per_file|
        out << %[\n## #{label}]
        per_file.each do |file, line_notes|
          out << %[\n### file://#{file}\n]
          line_notes.sort!{ |a,b| a[0] <=> b[0] }
          line_notes.each do |line, note|
            out << %[* #{note} (#{line})]
          end
        end
      end
      return out.join("\n")
    end

    # Format notes in XML format.
    #
    def to_xml
      xml = []
      xml << "<notes>"
      notes.each do |label, per_file|
        xml << %[<set label="#{label}">]
        per_file.each do |file, line_notes|
          xml << %[<file src="#{file}">]
          line_notes.sort!{ |a,b| a[0] <=> b[0] }
          line_notes.each do |line, note|
            note = REXML::Text.normalize(note)
            xml << %[<note line="#{line}" type="#{label}">#{note}</note>]
          end
          xml << %[</file>]
        end
        xml << %[</set>]
      end
      xml << "</notes>"
      return xml.join("\n")
    end

    # HTML format.
    #
    def to_html
      html = []
      html << %[<html>]
      html << %[<head>]
      html << %[<title><%= title %></title>]
      html << %[<style>]
      html << HTML_CSS
      html << %[</style>]
      html << %[</head>]
      html << %[<body>]
      html << %[<div class="main">]
      html << %[<h1><%= title %></h1>]
      html << %[<div class="notes">]
      notes.each do |label, per_file|
        html << %[<h2>#{label}</h2>]
        html << %[<ol class="set #{label.downcase}">]
        per_file.each do |file, line_notes|
          html << %[<li><h3><a href="#{file}">#{file}</a></h3><ol class="file" href="#{file}">]
          line_notes.sort!{ |a,b| a[0] <=> b[0] }
          line_notes.each do |line, note|
            note = REXML::Text.normalize(note)
            html << %[<li class="note #{label.downcase}" ref="#{line}">#{note} <sup>#{line}</sup></li>]
          end
          html << %[</ol></li>]
        end
        html << %[</ol>]
      end
      html << %[</div>]
      html << %[</div>]
      html << %[</boby>]
      html << %[</html>]
      html.join("\n")
    end

    #
    def to_yaml
      require 'yaml'
      notes.to_yaml
    end

    #
    def to_json
      require 'json'
      notes.to_json
    end

    # Save notes.
    #
    def write(text, format)
      if output.directory?
        file = output + "notes.#{format}"
      else
        file = Pathname.new(output)
      end
      fu.mkdir_p(file.parent)
      File.open(file, 'w') { |f| f << text } unless noharm?
      file
    end

    #
    def fu
      @fu ||= (
        if noop? and verbose?
          FileUtils::DryRun
        elsif noop
          FileUtils::Noop
        elsif verbose
          FileUtils::Verbose
        else
          FileUtils
        end
      )
    end

    HTML_CSS = <<-HERE
      body { margin: 0; padding: 0; }
      .main { width: 800px; margin: 0 auto; border: 1px solid #ccc; padding: 0 20px 20px 20px; }
      h1 { margin: 25px 0; }
      h2,h3,h4 { margin: 5px 0; padding: 0; color: 880044; }
      h3 { color: 004488; }
      h4 { color: 888844; }
      ul { margin: 0; padding: 0; text-align: left; }
      li { margin: 0; padding: 0; text-align: left; }
    HERE

  end

end

  #     out = ''
  #
  #     case format
  #     when 'yaml'
  #       out << records.to_yaml
  #     when 'list'
  #       records.each do |record|
  #         out << "* #{record['note']}\n"
  #       end
  #     else #when 'rdoc'
  #       labels.each do |label|
  #         recs = records.select{ |r| r['label'] == label }
  #         next if recs.empty?
  #         out << "\n= #{label}\n"
  #         last_file = nil
  #         recs.sort!{ |a,b| a['file'] <=> b['file'] }
  #         recs.each do |record|
  #           if last_file != record['file']
  #             out << "\n"
  #             last_file = record['file']
  #             out << "file://#{record['file']}\n"
  #           end
  #           out << "* #{record['note'].rstrip} (#{record['line']})\n"
  #         end
  #       end
  #       out << "\n---\n"
  #       out << counts.collect{|l,n| "#{n} #{l}s"}.join(' ')
  #       out << "\n"
  #     end

  #     # List TODO notes. Same as notes --label=TODO.
  #
  #     def todo( options={} )
  #       options = options.to_openhash
  #       options.label = 'TODO'
  #       notes(options)
  #     end
  #
  #     # List FIXME notes.  Same as notes --label=FIXME.
  #
  #     def fixme( options={} )
  #       options = options.to_openhash
  #       options.label = 'FIXME'
  #       notes(options)
  #     end

