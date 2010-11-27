require 'dnote/notes'

testcase DNote::Notes do

  concern "Coverage of DNote::Notes class."

  unit :labels => 'returns the list of labels' do
    notes = DNote::Notes.new([], :labels=>['TODO'])
    notes.labels.assert == ['TODO'] #DNote::Notes::DEFAULT_LABELS
  end

  unit :files => 'returns the files attribute' do
    notes = DNote::Notes.new(["example1.rb"])
    notes.assert.files == ["example1.rb"]
    notes = DNote::Notes.new([], :paths => ["example2.rb"])
    notes.assert.files == ["example2.rb"]
  end

  unit :files= => 'changes the paths attribute' do
    notes = DNote::Notes.new([])
    notes.files = ["example1.rb"]
    notes.assert.files == ["example1.rb"]
  end

  unit :match_general => '' do
    notes = DNote::Notes.new([])
    line, lineno, file = "# TODO: Do something or another!", 1, "foo.rb"
    rec = notes.match_general(line, lineno, file)
    rec.to_h.assert == {'label'=>"TODO",'file'=>file,'line'=>lineno,'text'=>"Do something or another!"}
  end

  unit :match_special => '' do
    notes = DNote::Notes.new([], :labels=>['TODO'])
    line, lineno, file = "# TODO: Do something or another!", 1, "foo.rb"
    rec = notes.match_special(line, lineno, file)
    rec.to_h.assert == {'label'=>"TODO",'file'=>file,'line'=>lineno,'text'=>"Do something or another!"}
  end

  unit :counts
  unit :notes
  unit :parse

end

