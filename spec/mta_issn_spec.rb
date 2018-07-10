# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:issn1) { run_traject_json('unc', 'issn1', 'mrc') }
  let(:issn2) { run_traject_json('unc', 'issn2', 'mrc') }
  
  it '(MTA) sets issn[primary] from multiple 022s' do
    result = issn1['issn']['primary']
    expect(result).to eq(
                        ['0140-6736', '0099-5355']
                        )
  end

  it '(MTA) sets issn[linking] from 022l' do
    result = issn2['issn']['linking']
    expect(result).to eq(
                        ['2213-9095']
                      )
  end

end
