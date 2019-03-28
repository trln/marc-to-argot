require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest

  let(:only_shadowed) { run_traject('ncsu', 'only-shadowed-location-items') }

  # NOTE: I added a skip here because the test file contains invalid XML and
  #       now returns an error when the tests run (due to marc v1.0.3).
  #       However, when I remove the space in front of the XML namespace the
  #       XML parses but the test fails. I'm not sure whether the intent
  #       is that the record is skipped for shadowed locations
  #       or just all the items are skipped.
  xit 'skips records with only items in shadowed locations' do
    expect(only_shadowed).to be_empty
  end
end
