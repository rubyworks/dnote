require 'rexml/text'
require 'pathname'
require 'erb'

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
    attr_accessor :title

    # Paths to search.
    attr_accessor :paths

    # Labels to document. Defaults are: TODO, FIXME, OPTIMIZE and DEPRECATE.
    attr_accessor :labels

    #
    def initialize(paths, options={})
      initialize_defaults
      options.each do |k, v|
        __send__("#{k}=", v)
      end
      #@paths = ['**/*.rb'] if @paths.empty?
      parse
    end

    #
    def initialize_defaults
      @labels   = DEFAULT_LABELS
      @paths    = ["**/*.rb"]
      @title    = "Developer's Notes"
      @format   = "rdoc"
    end

    #
    def notes
      @notes
    end

    #
    def counts
      @counts
    end

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

    #
    def labels=(labels)
      @labels = (
        case labels
        when String
          labels.split(/[:;,]/)
        else
          labels = [labels].flatten.compact.uniq.map{ |s| s.to_s }
        end
      )
    end

    # Gather and count notes. This returns two elements,
    # a hash in the form of label=>notes and a counts hash.

    def parse
      records, counts = [], Hash.new(0)
      files.each do |fname|
        next unless File.file?(fname)
        #next unless fname =~ /\.rb$/      # TODO: should this be done?
        File.open(fname) do |f|
          lineno, save, text = 0, nil, nil
          while line = f.gets
            lineno += 1
            save = match_common(line, lineno, fname) || match_arbitrary(line, lineno, fname)
            if save
              #file = fname
              text = save['note']
              #save = {'label'=>label,'file'=>file,'line'=>line_no,'note'=>text}
              records << save
              counts[save['label']] += 1
            else
              if text
                if line =~ /^\s*[#]{0,1}\s*$/ or line !~ /^\s*#/ or line =~ /^\s*#[+][+]/
                  text.strip!
                  text = nil
                else
                  text << ' ' << line.gsub(/^\s*#\s*/,'')
                end
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

    #
    def files
      @files ||= (
        self.paths.map do |path|
          if File.directory?(path)
            Dir.glob(File.join(path, '**/*'))
          else
            Dir.glob(path)
          end
        end.flatten.uniq
      )
    end

    #
    def match_common(line, lineno, file)
      rec = nil
      labels.each do |label|
        if md = /\#\s*#{Regexp.escape(label)}[:]?\s*(.*?)$/.match(line)
          text = md[1]
          rec = {'label'=>label,'file'=>file,'line'=>lineno,'note'=>text}
        end
      end
      return rec
    end

    #
    def match_arbitrary(line, lineno, file)
      rec = nil
      labels.each do |label|
        if md = /\#\s*([A-Z]+)[:]\s*(.*?)$/.match(line)
          label, text = md[1], md[2]
          rec = {'label'=>label,'file'=>file,'line'=>lineno,'note'=>text}
        end
      end
      return rec
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
    def to(format)
      __send__("to_#{format}")
    end

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
      html << to_html_list
      html << %[</div>]
      html << %[</boby>]
      html << %[</html>]
      html.join("\n")
    end

    #
    def to_html_list
      html = []
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
      html.join("\n")
    end

    #
    def to_yaml
      require 'yaml'
      notes.to_yaml
    end

    #
    def to_json
      require 'json'  # TODO: fallback to json_pure
      notes.to_json
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

