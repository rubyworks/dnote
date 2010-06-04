require 'dnote/notes'

Case DNote::Notes do

  Concern "Basic coverage of DNote::Notes class."

  Unit :labels => 'returns the list of labels' do
    notes = DNote::Notes.new([], :labels=>['TODO'])
    notes.labels.assert == ['TODO'] #DNote::Notes::DEFAULT_LABELS
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

  Unit :match_general => '' do
    notes = DNote::Notes.new([])
    line, lineno, file = "# TODO: Do something or another!", 1, "foo.rb"
    rec = notes.match_general(line, lineno, file)
    rec.to_h.assert == {'label'=>"TODO",'file'=>file,'line'=>lineno,'text'=>"Do something or another!"}
  end

  Unit :match_specail => '' do
    notes = DNote::Notes.new([], :labels=>['TODO'])
    line, lineno, file = "# TODO: Do something or another!", 1, "foo.rb"
    rec = notes.match_special(line, lineno, file)
    rec.to_h.assert == {'label'=>"TODO",'file'=>file,'line'=>lineno,'text'=>"Do something or another!"}
  end

  Unit :counts
  Unit :notes
  Unit :parse

end

