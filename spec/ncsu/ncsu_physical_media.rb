require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:game) { run_traject_json('ncsu', 'game') }

  it 'does not set physical media Print for a game' do
    types = game['physical_media']
    expect(type).to be_a(Array)
    expect(types).to be_empty
  end
end
