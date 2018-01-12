require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest

  let(:only_shadowed) { run_traject('ncsu', 'only-shadowed-location-items') }

  it 'skips records with only items in shadowed locations' do
    expect(only_shadowed).to be_empty
  end
end
