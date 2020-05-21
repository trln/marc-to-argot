  # coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:title1) { run_traject_json('unc', 'title_main1', 'mrc') }
  let(:title2) { run_traject_json('duke', 'title_sort', 'xml') }
  let(:vtitle1) { run_traject_json('unc', 'vern_title1', 'mrc') }
  let(:vtitle2) { run_traject_json('unc', 'vern_title2', 'mrc') }

  it '(MTA) sets title_main' do
    result = title1['title_main']
    expect(result).to eq(
                        [
                          {'value' => 'The Whitechapel murders papers : letters relating to the "Jack the Ripper" killings, 1888-1889.'}
                        ]
                      )
  end

  it '(MTA) sets short_title' do
    rec = make_rec
    rec << MARC::DataField.new('245', '0', '0', ['a', 'three word title :'], ['b', 'subtitle'], ['z', '9789575433741'])
    result = run_traject_on_record('ncsu', rec)
    expect(result['short_title'].first).to eq('three word title')
  end

  it '(MTA) sets title_sort' do
    result = title1['title_sort']
    expect(result).to eq(
                        'whitechapel murders papers letters relating to the jack the ripper killings 1888 1889'
                      )
  end

  it '(MTA) sets the title_sort and transliterates accented characters.' do
    result = title2['title_sort']
    expect(result).to eq(
      'jusquau sombre plaisir dun coeur melancolique etudes de litterature '\
      'francaise du xviie siecle offertes a patrick dandrey'
    )
  end

  it '(MTA) sets vernacular title_main from 880' do
    result = vtitle1['title_main']
    expect(result).to eq(
                        [
                          {'value'=>'Urbilder ; Blossoming ; Kalligraphie ; O Mensch, bewein\' dein\' Sünde gross (Arrangement) : for string quartet'},
                          {'value'=>'原像 ; 開花 ; 書 （カリグラフィー） ほか : 弦楽四重奏のための',
                           'lang'=>'cjk'}
                        ]
                      )
  end

  it '(MTA) sets vernacular title_main from 245' do
    result = vtitle2['title_main']
    expect(result).to eq(
                        [
                          {'value'=>'近代日本文学研究の問題点',
                           'lang'=>'cjk'}
                        ]
                      )
  end

end
