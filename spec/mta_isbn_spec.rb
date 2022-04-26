# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:visbn1) { run_traject_json('unc', 'vern_isbn1', 'mrc') }

  it "isbn result set shouldn't have duplicates" do
    rec = make_rec
    rec << MARC::DataField.new('020', ' ', ' ', ['z', '9789575433741'])
    rec << MARC::DataField.new('776', ' ', ' ', ['z', '9789575433741'])
    result = run_traject_on_record('ncsu', rec)
    expect(result['isbn']).to eq([{number: '9789575433741', qualifying_info: ''}])
  end

  xit '(MTA) sets vernacular isbn qualifiers' do
    result = visbn1['isbn']
    expect(result).to eq(
                        [
                          {
                            'number'=>'9575433742',
                            'qualifying_info'=>'ping zhuang'
                          },
                          {
                            'number'=>'9789575433741',
                            'qualifying_info'=>'ping zhuang'
                          },
                          {
                            'number'=>'9575433742',
                            'qualifying_info'=>'平裝'
                          }
                        ])
  end

end
