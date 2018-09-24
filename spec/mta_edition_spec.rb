# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:edition1) { run_traject_json('unc', 'edition1', 'mrc') }
  let(:edition2) { run_traject_json('unc', 'edition2', 'mrc') }
  let(:edition3) { run_traject_json('unc', 'edition3', 'mrc') }
  let(:edition4) { run_traject_json('unc', 'edition4', 'mrc') }
  let(:edition_v1) { run_traject_json('unc', 'edition_v1', 'mrc') }
  let(:edition_v2) { run_traject_json('unc', 'edition_v2', 'mrc') }
  
  it '(MTA) sets edition from 250 with $3' do
    result = edition1['edition']
    expect(result).to eq(
                        [
                          {'label' => 'Vol. 2', 'value' => '1a ed.'}
                        ]
                      )
  end

  it '(MTA) sets edition from 250 and 254 fields' do
    result = edition2['edition']
    expect(result).to eq(
                        [
                          {'value' => '3rd ed.'},
                          {'value' => 'Choir edition.'}
                        ]
                      )
  end

  it '(MTA) sets edition from 254 field' do
    result = edition3['edition']
    expect(result).to eq(
                        [
                           {'value' => 'Study score.'}
                        ]
                      )
  end

  it '(MTA) sets edition from 250 $a and $b' do
    result = edition4['edition']
    expect(result).to eq(
                        [
                          {'value' => 'Prathama saṃskaraṇa = First edition.'}
                        ]
                      )
  end

  xit '(MTA) sets edition from 250 and linked 880' do
    result = edition_v1['edition']
    expect(result).to eq(
                        [
                          {'value' => '︠I︡Ubileĭnoe izd.' },
                          { 'value' => 'Юбилейное изд.',
                            'lang' => 'rus' }
                        ]
                      )
  end

  xit '(MTA) sets edition from non-Roman 250' do
    result = edition_v2['edition']
    expect(result).to eq(
                        [
                          { 'value' => '2015年デジタル版',
                            'lang' => 'cjk' }
                        ]
                      )
  end
end


