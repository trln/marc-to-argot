# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:phys_desc) { run_traject_json('unc', 'phys_desc', 'mrc') }
  
  xit '(MTA) sets physical_description from 300 field' do
    result = phys_desc['physical_description']
    expect(result).to eq(
                        [ {'label' => 'videodiscs',
                           'value' => '1 videodisc (107 min.) : sound, color ; 4 3/4 in.'},
                          {'label' => 'volumes',
                           'value' => '286 pages : illustrations ; 21 cm.'},
                          {'label' => 'print',
                           'value' => '1 reel of 1 (18 min., 30 sec.) (656 ft.) : opt sd., b&w ; 16 mm. + with study guide.'}
                        ]
                      )
  end
end


