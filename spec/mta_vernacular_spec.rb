# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:title1) { run_traject_json('unc', 'vern_title1', 'mrc') }
  let(:title2) { run_traject_json('unc', 'vern_title2', 'mrc') }
  
  xit '(MTA) sets vernacular title_main from 880' do
    result = title1['title_main']
    expect(result).to eq(
                        [
                          {'value'=>'Urbilder ; Blossoming ; Kalligraphie ; O Mensch, bewein\' dein\' Sünde gross (Arrangement) : for string quartet'},
                          {'value'=>'原像 ; 開花 ; 書 （カリグラフィー） ほか : 弦楽四重奏のための',
                           'lang'=>'cjk'}
                        ]
                      )
  end

  xit '(MTA) sets vernacular title_main from 245' do
    result = title2['title_main']
    expect(result).to eq(
                        [
                          {'value'=>'近代日本文学研究の問題点',
                           'lang'=>'cjk'}
                        ]
                      )
  end
  
end
