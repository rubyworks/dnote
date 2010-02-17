require 'dnote/notes'

Case DNote::Notes do

  Concern "Full coverage of DNote::Notes class."

  Unit :labels => 'returns the list of labels' do
    notes = DNote::Notes.new([])
    notes.labels.assert == DNote::Notes::DEFAULT_LABELS
  end

  Unit :labels= => 'changes the list of labels' do
    notes = DNote::Notes.new([])
    notes.labels = [:CHOICE]
    notes.labels.assert == ['CHOICE']
  end

  Unit :files => 'returns the files attribute' do
    notes = DNote::Notes.new(["example1.rb"])
    notes.assert.files == ["example1.rb"]
    notes = DNote::Notes.new([], :paths => ["example2.rb"])
    notes.assert.files == ["example2.rb"]
  end

  Unit :files= => 'changes the paths attribute' do
    notes = DNote::Notes.new([])
    notes.files = ["example1.rb"]
    notes.assert.files == ["example1.rb"]
  end

  Unit :match_arbitrary => '' do
    notes = DNote::Notes.new([])
    line, lineno, file = "# TODO: Do something or another!", 1, "foo.rb"
    rec = notes.match_arbitrary(line, lineno, file)
    rec.to_h.assert == {'label'=>"TODO",'file'=>file,'line'=>lineno,'text'=>"Do something or another!"}
  end

  Unit :match_common
  Unit :to_xml
  Unit :notes
  Unit :to
  Unit :initialize_defaults
  Unit :parse
  Unit :to_yaml
  Unit :to_json
  Unit :counts

end

