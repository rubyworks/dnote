require 'spec_helper'

describe(DNote::Notes) do
  describe(:labels) do
    it('returns the list of labels') do
      notes = DNote::Notes.new([], labels: ['TODO'])
      expect(notes.labels).to eq(['TODO'])
    end
  end
  describe(:files) do
    it('returns the files attribute') do
      notes = DNote::Notes.new(['example1.rb'])
      expect(notes.files).to eq(['example1.rb'])
    end
  end
  describe(:files) do
    it('changes the paths attribute') do
      notes = DNote::Notes.new([])
      notes.files = ['example1.rb']
      expect(notes.files).to eq(['example1.rb'])
    end
  end
  describe(:match_general) do
    it('works') do
      notes = DNote::Notes.new([])
      line = '# TODO: Do something or another!'
      lineno = 1
      file = 'foo.rb'
      rec = notes.match_general(line, lineno, file)
      expect(rec.to_h).to eq('label' => 'TODO', 'file' => file, 'line' => lineno, 'text' => 'Do something or another!')
    end
  end
  describe(:match_special) do
    it('works') do
      notes = DNote::Notes.new([], labels: ['TODO'])
      line = '# TODO: Do something or another!'
      lineno = 1
      file = 'foo.rb'
      rec = notes.match_special(line, lineno, file)
      expect(rec.to_h).to eq('label' => 'TODO', 'file' => file, 'line' => lineno, 'text' => 'Do something or another!')
    end
  end
  describe(:counts) { it { skip('pending') } }
  describe(:notes) { it { skip('pending') } }
  describe(:parse) { it { skip('pending') } }
end
