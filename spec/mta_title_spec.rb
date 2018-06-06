# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:title1) { run_traject_json('unc', 'title_main1', 'mrc') }
  
  xit '(MTA) sets title_main' do
    result = title1['title_main']
    expect(result).to eq(
                        [
                          {'value' => 'The Whitechapel murders papers : letters relating to the "Jack the Ripper" killings, 1888-1889.'}
                        ]
                      )
  end

    xit '(MTA) sets title_sort' do
    result = title1['title_sort']
    expect(result).to eq(
                        'Whitechapel murders papers : letters relating to the "Jack the Ripper" killings, 1888-1889.'
                      )
  end

end


