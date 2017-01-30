require 'dnote/notes'
require 'minitest/autorun'

describe DNote::Notes do

  describe :labels do
    it 'returns the list of labels' do
      notes = DNote::Notes.new([], :labels=>['TODO'])
      notes.labels.must_equal ['TODO'] #DNote::Notes::DEFAULT_LABELS
    end
  end

  describe :files do
    it 'returns the files attribute' do
      notes = DNote::Notes.new(["example1.rb"])
      notes.files.must_equal ["example1.rb"]
      notes = DNote::Notes.new([], :paths => ["example2.rb"])
      notes.files.must_equal ["example2.rb"]
    end
  end

  describe :files do
    it 'changes the paths attribute' do
      notes = DNote::Notes.new([])
      notes.files = ["example1.rb"]
      notes.files.must_equal ["example1.rb"]
    end
  end

  describe :match_general do
    it 'works' do
      notes = DNote::Notes.new([])
      line, lineno, file = "# TODO: Do something or another!", 1, "foo.rb"
      rec = notes.match_general(line, lineno, file)
      rec.to_h.must_equal({'label'=>"TODO",'file'=>file,'line'=>lineno,'text'=>"Do something or another!"})
    end
  end

  describe :match_special do
    it 'works' do
      notes = DNote::Notes.new([], :labels=>['TODO'])
      line, lineno, file = "# TODO: Do something or another!", 1, "foo.rb"
      rec = notes.match_special(line, lineno, file)
      rec.to_h.must_equal({'label'=>"TODO",'file'=>file,'line'=>lineno,'text'=>"Do something or another!"})
    end
  end

  describe :counts do
    it { skip 'pending' }
  end

  describe :notes do
    it { skip 'pending' }
  end

  describe :parse do
    it { skip 'pending' }
  end

end

