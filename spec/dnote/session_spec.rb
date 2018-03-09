require 'spec_helper'

RSpec.describe DNote::Session do
  describe '.main' do
    it 'generates notes list' do
      expect { DNote::Session.main }.
        to output(/1. This is a test of an arbitrary label./).to_stdout.
        and output(/1 TESTs/).to_stderr
    end
  end
end
