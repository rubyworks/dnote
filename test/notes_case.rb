require 'lemon'
require 'ae'
require 'dnote/notes'

testcase DNote::Notes do

  concern "Coverage of DNote::Notes class."

  method :labels do
    test 'returns the list of labels' do
      notes = DNote::Notes.new([], :labels=>['TODO'])
      notes.labels.assert == ['TODO'] #DNote::Notes::DEFAULT_LABELS
    end
  end

  method :files do
    test 'returns the files attribute' do
      notes = DNote::Notes.new(["example1.rb"])
      notes.assert.files == ["example1.rb"]
      notes = DNote::Notes.new([], :paths => ["example2.rb"])
      notes.assert.files == ["example2.rb"]
    end
  end

  method :files do
    test 'changes the paths attribute' do
      notes = DNote::Notes.new([])
      notes.files = ["example1.rb"]
      notes.assert.files == ["example1.rb"]
    end
  end

  method :match_general do
    test 'works' do
      notes = DNote::Notes.new([])
      line, lineno, file = "# TODO: Do something or another!", 1, "foo.rb"
      rec = notes.match_general(line, lineno, file)
      rec.to_h.assert == {'label'=>"TODO",'file'=>file,'line'=>lineno,'text'=>"Do something or another!"}
    end
  end

  method :match_special do
    test 'works' do
      notes = DNote::Notes.new([], :labels=>['TODO'])
      line, lineno, file = "# TODO: Do something or another!", 1, "foo.rb"
      rec = notes.match_special(line, lineno, file)
      rec.to_h.assert == {'label'=>"TODO",'file'=>file,'line'=>lineno,'text'=>"Do something or another!"}
    end
  end

  method :counts do
    test{ raise NotImplementedError }
  end

  method :notes do
    test{ raise NotImplementedError }
  end

  method :parse do
    test{ raise NotImplementedError }
  end

end

