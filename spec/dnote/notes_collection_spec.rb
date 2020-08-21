# frozen_string_literal: true

require "spec_helper"

RSpec.describe(DNote::NotesCollection) do
  let(:bar_todo) { instance_double(DNote::Note, file: "bar.rb", label: "TODO", line: 1) }
  let(:bar_hack) { instance_double(DNote::Note, file: "bar.rb", label: "HACK", line: 9) }
  let(:foo_todo) { instance_double(DNote::Note, file: "foo.rb", label: "TODO", line: 4) }
  let(:foo_hack) { instance_double(DNote::Note, file: "foo.rb", label: "HACK", line: 8) }
  let(:notes_collection) { described_class.new([bar_todo, bar_hack, foo_todo, foo_hack]) }

  describe("#counts") do
    it "returns correct counts" do
      expect(notes_collection.counts).to eq("HACK" => 2,
                                            "TODO" => 2)
    end
  end

  describe("#by_file") do
    it "returns notes grouped by file" do
      expect(notes_collection.by_file).to eq("bar.rb" => [bar_todo, bar_hack],
                                             "foo.rb" => [foo_todo, foo_hack])
    end
  end

  describe("#by_file_label") do
    it "returns notes grouped by file then label" do
      expect(notes_collection.by_file_label)
        .to eq("bar.rb" => { "TODO" => [bar_todo], "HACK" => [bar_hack] },
               "foo.rb" => { "TODO" => [foo_todo], "HACK" => [foo_hack] })
    end
  end

  describe("#by_label") do
    it "returns notes grouped by label" do
      expect(notes_collection.by_label).to eq("HACK" => [bar_hack, foo_hack],
                                              "TODO" => [bar_todo, foo_todo])
    end
  end

  describe("#by_label_file") do
    it "returns notes grouped by label then file" do
      expect(notes_collection.by_label_file)
        .to eq("HACK" => { "bar.rb" => [bar_hack], "foo.rb" => [foo_hack] },
               "TODO" => { "bar.rb" => [bar_todo], "foo.rb" => [foo_todo] })
    end
  end
end
