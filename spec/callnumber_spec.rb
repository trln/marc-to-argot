require 'spec_helper'
require 'marc_to_argot'

describe MarcToArgot::CallNumbers do
  # helps namespace calls to LCC classes
  class Testy
    include MarcToArgot::CallNumbers

    def root
      LCC.root
    end

    def path(callnum)
      LCC.find_path(callnum)
    end
  end

  before(:each) do
    @test = Testy.new
  end

  it 'loads LCC tree' do
    expect(@test.root).to be_instance_of(MarcToArgot::CallNumbers::LCC::Range)
  end

  it 'maps call numbers to paths' do
    expected_path = ['A - General Works',
                     'AC1 - AC999 Collections. Series. Collected works',
                     'AC1 - AC195 Collections of monographs, essays, etc.',
                     'AC9 - AC195 Other languages']
    expect(@test.path('AC 101')).to eq(expected_path)
  end
end
