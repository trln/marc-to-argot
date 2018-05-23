# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:edition1) { run_traject_json('unc', 'edition1', 'mrc') }
  let(:edition2) { run_traject_json('unc', 'edition2', 'mrc') }
  let(:edition3) { run_traject_json('unc', 'edition3', 'mrc') }
  let(:edition4) { run_traject_json('unc', 'edition4', 'mrc') }
  
  xit '(MTA) sets edition from 250 with $3' do
    result = edition1['edition']
    expect(result).to eq(
                        [
                          {'label' => 'Vol. 2', 'value' => '1a ed.'}
                        ]
                      )
  end

  xit '(MTA) sets edition from 250 and 254 fields' do
    result = edition2['edition']
    expect(result).to eq(
                        [
                          {'value' => '3rd ed.'},
                          {'value' => 'Choir edition.'}
                        ]
                      )
  end

  xit '(MTA) sets edition from 254 field' do
    result = edition3['edition']
    expect(result).to eq(
                        [
                           {'value' => 'Study score.'}
                        ]
                      )
  end

  xit '(MTA) sets edition from 250 $a and $b' do
    result = edition4['edition']
    expect(result).to eq(
                        [
                          {'value' => 'Prathama saṃskaraṇa = First edition.'}
                        ]
                      )
  end
end


