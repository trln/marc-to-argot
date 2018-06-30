# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:lang1) { run_traject_json('unc', 'language1', 'mrc') }
  let(:lang2) { run_traject_json('unc', 'language2', 'mrc') }
  let(:lang3) { run_traject_json('unc', 'language3', 'mrc') }
  let(:lang4) { run_traject_json('unc', 'language4', 'mrc') }
  
  it '(MTA) does not set language from 041h' do
    result = lang1['language']
    expect(result).to eq(
                        [
                          "English"
                        ]
                      )
  end

  it '(MTA) does not set language from 041 with i1=1 and $a longer than one language code' do
    result = lang2['language']
    expect(result).to eq(
                        [
                          "English"
                        ]
                      )
  end

  it '(MTA) sets language from legacy 041 with i1!=1 and $a longer than one language code' do
    result = lang3['language']
    expect(result).to eq(
                        [
                          'English',
                          'French',
                          'Italian',
                          'Latin'
                        ]
                      )
  end

  it '(MTA) sets language from complex legacy 041 with i1=1, $a longer than one language code, but other usable fields present' do
    result = lang4['language']
    #adeg
    expect(result).to eq(
                        [
                          'Danish',
                          'Belarusian',
                          'Balinese',
                          'Burmese',
                          'Bosnian'
                        ]
                      )
  end

end

