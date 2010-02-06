require 'dnote/notes'

Case DNote::Notes do

  Concern "Full coverage of DNote::Notes class."

  Unit :paths

  Unit :labels => 'returns the list of labels' do
    notes = DNote::Notes.new([])
    notes.labels.assert == DNote::Notes::DEFAULT_LABELS
  end

  Unit :labels= => 'changes the list of labels' do
    notes = DNote::Notes.new([])
    notes.labels = [:CHOICE]
    notes.labels.assert == ['CHOICE']
  end

  Unit :title => 'returns the title attribute' do
    notes = DNote::Notes.new([], :title => "WHATFORE")
    notes.assert.title == "WHATFORE"
  end

  Unit :title= => 'changes the title attribute' do
    notes = DNote::Notes.new([], :title => "WHATFORE")
    notes.assert.title == "WHATFORE"
    notes.title = "WHATSUP"
    notes.assert.title == "WHATSUP"
  end

  Unit :files

  Unit :match_arbitrary => '' do
    notes = DNote::Notes.new([])
    line, lineno, file = "# TODO: Do something or another!", 1, "foo.rb"
    rec = notes.match_arbitrary(line, lineno, file)
    rec.assert == {'label'=>"TODO",'file'=>file,'line'=>lineno,'note'=>"Do something or another!"}
  end

  Unit :match_common
  Unit :to_rdoc
  Unit :to_xml
  Unit :notes
  Unit :to
  Unit :initialize_defaults
  Unit :to_markdown
  Unit :paths=
  Unit :parse
  Unit :to_yaml
  Unit :to_json
  Unit :counts
  Unit :to_html
  Unit :organize
  Unit :display

  Unit :to_html_list do
    raise
  end

end

