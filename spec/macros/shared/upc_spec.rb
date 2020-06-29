# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::Shared::Upc do
  include Util::TrajectRunTest
  let(:upc01) { run_traject_json('unc', 'misc_id_upc', 'mrc') }
  let(:upc024) { run_traject_json('nccu', 'primary_upc', 'xml') }
  
  it '(MTA) sets upc' do
    result = upc01['upc']
    expect(result).to eq(
                        [
                          {'value' => '034571173412',
                           'type' => 'UPC'},
                          {'value' => '111',
                           'qual' => 'blah',
                           'type' => 'UPC'},
                          {'value' => '666',
                           'type' => 'UPC (canceled or invalid)'}
                        ]
    )
  end

  it '(MTA) sets primary_upc' do
    result = upc01['primary_upc']
    expect(result).to eq(["034571173412", "111", "666"])
  end

  it '(MTA) sets upc when $q exclude' do
    result = upc024['upc']
    expect(result).to eq(
                        [
                          {'value' => 'hein4792868',
                           'qual' => 'exclude',
                           'type' => 'UPC'},
                        ]
    )
  end

  it '(MTA) sets primary_upc when $q exclude' do
    result = upc024['primary_upc']
    expect(result).to eq(nil)
  end
end
