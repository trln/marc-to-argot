# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:title1) { run_traject_json('unc', 'vern_title1', 'mrc') }
  let(:title2) { run_traject_json('unc', 'vern_title2', 'mrc') }
  let(:this_work1) { run_traject_json('unc', 'vern_this_work1', 'mrc') }
  let(:this_work2) { run_traject_json('unc', 'vern_this_work2', 'mrc') }
  let(:this_work3) { run_traject_json('unc', 'vern_this_work3', 'mrc') }  
  let(:this_work4) { run_traject_json('unc', 'vern_this_work4', 'mrc') }
  let(:this_work5) { run_traject_json('unc', 'vern_this_work5', 'mrc') }
  
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

    xit '(MTA) sets vernacular this_work from 880s linked to 100 & 240' do
    result = this_work1['this_work']
    expect(result).to eq(
                        [
                          {'type'=>'this',
                           'author'=>'Han, Fei, -233 B.C.',
                           'title'=>['Han Feizi']
                          },
                          {'type'=>'this',
                           'author'=>'韓非, -233 B.C.',
                           'title'=>['韓非子'],
                           'lang'=>'cjk'
                          }
                        ]
                      )
  end

    xit '(MTA) sets vernacular this_work from 100 and 880 linked to 240' do
      result = this_work2['this_work']
      expect(result).to eq(
                          [
                            {'type'=>'this',
                             'author'=>'Ōkuma, Kotomichi, 1798-1868.',
                             'title'=>['Sōkeishū.', 'Selections.', 'English']
                            },
                            {'type'=>'this',
                             'author'=>'Ōkuma, Kotomichi, 1798-1868.',
                             'title'=>['草徑集.', 'Selections.', 'English'],
                             'lang'=>'cjk'
                            }
                          ]
                        )
    end

    xit '(MTA) sets vernacular this_work from 240 and 880 linked to 100' do
      result = this_work3['this_work']
      expect(result).to eq(
                          [
                            {'type'=>'this',
                             'author'=>'Bingxin, 1900-1999.',
                             'title'=>['Works.', '1982']
                            },
                            {'type'=>'this',
                             'author'=>'冰心, 1900-1999.',
                             'title'=>['Works.', '1982'],
                             'lang'=>'cjk'
                            }
                          ]
                        )
    end

    xit '(MTA) sets vernacular this_work from 100 and 880 linked to 245' do
      result = this_work4['this_work']
      expect(result).to eq(
                          [
                            {'type'=>'this',
                             'author'=>'Mif, P.$q(Pavel), 1901-',
                             'title'=>['Fa zhan zhuo de Zhongguo ge ming gao chao']
                            },
                            {'type'=>'this',
                             'author'=>'Mif, P.$q(Pavel), 1901-',
                             'title'=>['發展著的中國革命高潮'],
                             'lang'=>'cjk'
                            }
                          ]
                        )
    end

    xit '(MTA) sets vernacular this_work from 100 and 880 linked to 245' do
      result = this_work5['this_work']
      expect(result).to eq(
                          [
                            {'type'=>'this',
                             'author'=>'高田, 時雄.',
                             'title'=>['梵蒂岡圖書館所藏漢籍目録補編'],
                             'lang'=>'cjk'
                            }
                          ]
                        )
    end

end
