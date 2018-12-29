# frozen_string_literal: true

require 'spec_helper'

describe(DNote::Notes) do
  let(:line) { '# TODO: Do something or another!' }
  let(:file) { 'foo.rb' }
  let(:lineno) { 1 }

  describe('#labels') do
    it('returns the list of labels') do
      notes = described_class.new([], labels: ['TODO'])
      expect(notes.labels).to eq(['TODO'])
    end
  end

  describe('#files') do
    it('returns the files attribute') do
      notes = described_class.new([file])
      expect(notes.files).to eq([file])
    end
  end

  describe('#files=') do
    it('changes the paths attribute') do
      notes = described_class.new([])
      notes.files = [file]
      expect(notes.files).to eq([file])
    end
  end

  describe('#match_general') do
    it('works') do
      notes = described_class.new([])
      rec = notes.match_general(line, lineno, file)
      expect(rec.to_h).to eq('label' => 'TODO', 'file' => file, 'line' => lineno, 'text' => 'Do something or another!')
    end
  end

  describe('#match_special') do
    it('works') do
      notes = described_class.new([], labels: ['TODO'])
      rec = notes.match_special(line, lineno, file)
      expect(rec.to_h).to eq('label' => 'TODO', 'file' => file, 'line' => lineno, 'text' => 'Do something or another!')
    end
  end

  describe('#counts') { it { skip('pending') } }

  describe('#notes') { it { skip('pending') } }

  describe('#parse') { it { skip('pending') } }
end
