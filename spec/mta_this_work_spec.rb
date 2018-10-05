# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:this_work00_1) { run_traject_json('unc', 'this_work00-1', 'mrc') }
  let(:this_work00_2) { run_traject_json('unc', 'this_work00-2', 'mrc') }
  let(:this_work00_3) { run_traject_json('unc', 'this_work00-3', 'mrc') }
  let(:this_work01) { run_traject_json('unc', 'this_work01', 'mrc') }
  let(:this_work02) { run_traject_json('unc', 'this_work02', 'mrc') }
  let(:this_work03) { run_traject_json('unc', 'this_work03', 'mrc') }
  let(:this_work04) { run_traject_json('unc', 'this_work04', 'mrc') }
  let(:this_work05) { run_traject_json('unc', 'this_work05', 'mrc') }
  let(:this_work06) { run_traject_json('unc', 'this_work06', 'mrc') }
  let(:this_work10) { run_traject_json('unc', 'this_work10', 'mrc') }
  let(:this_work11) { run_traject_json('unc', 'this_work11', 'mrc') }
  let(:this_work12) { run_traject_json('unc', 'this_work12', 'mrc') }
  let(:this_work13) { run_traject_json('unc', 'this_work13', 'mrc') }
  let(:this_work14) { run_traject_json('unc', 'this_work14', 'mrc') }
  let(:this_work1) { run_traject_json('unc', 'this_work_v1', 'mrc') }
  let(:this_work2) { run_traject_json('unc', 'this_work_v2', 'mrc') }
  let(:this_work3) { run_traject_json('unc', 'this_work_v3', 'mrc') }  

  context '100 field present' do
    context 'AND 100 field contains title subfield(s)' do
      it '(MTA) sets author-title this_work from 100' do
        result = this_work00_1['this_work']
        expect(result).to eq(
                            [{'type'=>'this',
                              'author'=>'Kuzmin, M. A. (Mikhail Alekseevich), 1872-1936.',
                              'title'=>['Works.', 'Selections.', '1977.']}
                            ])
      end
    end

    context 'AND 100 does NOT contain title subfield(s)' do
      context 'AND 240 field present' do
        context 'AND 240 indicator 1 = 0' do
          context 'AND 100 contains relator term/code' do
            it '(MTA) sets author-title this_work from 100 + 240, omitting relator term' do
              result = this_work01['this_work']
              expect(result).to eq(
                                  [{'type'=>'this',
                                    'author'=>'Landis, Thomas D.',
                                    'title'=>['Container tree nursery manual.', 'Spanish']}
                                  ])
            end
          end
        end

        context 'AND 240 indicator 1 = 1' do
          it '(MTA) sets author-title this_work from 100 + 240' do
            result = this_work02['this_work']
            expect(result).to eq(
                                [{'type'=>'this',
                                  'author'=>'Camus, Albert, 1913-1960.',
                                  'title'=>['Étranger.', 'English']}
                                ])
          end

          context 'AND 240 indicator 2 > 0 (non-filing characters recorded)' do
            it '(MTA) sets author-title this_work from 100 + 240, respecting non-filing characters' do
              result = this_work03['this_work']
              expect(result).to eq(
                                  [{'type'=>'this',
                                    'author'=>'Burton, Robert Wilton, 1848-1917.',
                                    'title'=>['Remnant truth'],
                                    'title_nonfiling'=>'De remnant truth'}
                                  ])
            end
          end

          context 'AND 880 linked to 100 AND 240 present' do
            xit '(MTA) sets non-Roman this_work from 880s linked to 100 & 240' do
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
          end

          context 'AND 880 linked to 240 BUT NOT 100 present' do
            xit '(MTA) reuses author from 100 in non-Roman this_work field' do
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
          end

          context 'AND 880 linked to 100 BUT NOT 240 present' do
            xit '(MTA) reuses title from 240 in non-Roman this_work field' do
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
          end
        end
      end

      context 'AND 240 field NOT present' do
        it '(MTA) does NOT set this_work field' do
          result = this_work06['this_work']
          expect(result).to be_nil
        end
      end
    end
  end

  context '110 field present' do
    context 'AND 110 field contains title subfield(s)' do
      it '(MTA) sets author-title this_work from 110' do
        result = this_work00_2['this_work']
        expect(result).to eq(
                            [{'type'=>'this',
                              'author'=>'Pennsylvania.',
                              'title'=>['Laws, etc.', '1825.']}
                            ])
      end
    end

    context 'AND 110 does NOT contain title subfield(s)' do
      context 'AND 240 field present' do
        context 'AND 110 contains relator term/code' do
          it '(MTA) sets author-title this_work from 110 + 240, omitting relator term' do
            result = this_work04['this_work']
            expect(result).to eq(
                                [{'type'=>'this',
                                  'author'=>'El Salvador',
                                  'title'=>['Constitución política (1983).', 'English']}
                                ])
          end
        end
      end
    end
  end

  context '111 field present' do
    context 'AND 111 field contains title subfield(s)' do
      it '(MTA) sets author-title this_work from 111' do
        result = this_work00_3['this_work']
        expect(result).to eq(
                            [{'type'=>'this',
                              'author'=>'International Congress of Human Sciences in Asia and North Africa (30th : 1976 : Mexico City, Mexico).',
                              'title'=>['Expansión hispanoamericana en Asia.', 'English.']}
                            ])
      end
    end

    context 'AND 111 does NOT contain title subfield(s)' do
      context 'AND 240 field present' do
        it '(MTA) sets author-title this_work from 111 + 240' do
          result = this_work05['this_work']
          expect(result).to eq(
                              [{'type'=>'this',
                                'author'=>'Consulta Latinoamericana de Iglesia y Sociedad (2nd : 1966 : El Tabo, Chile)',
                                'title'=>['América hoy.', 'English']}
                              ])
        end      
      end

      context 'AND 240 field NOT present' do
        it '(MTA) does NOT set this_work' do
          result = this_work10['this_work']
          expect(result).to be_nil
        end
      end
    end
  end

  context '130 field present' do
    context 'AND 130 indicator 1 = 0 or blank' do
      it '(MTA) sets title-only this_work from entire 130' do
        result = this_work11['this_work']
        expect(result).to eq(
                            [{'type'=>'this',
                              'title'=>['Bible.', 'New Testament.', 'Latin.', 'Vulgate.', '1541.']}
                            ])
      end
    end

    context 'AND 130 indicator 1 > 0' do
      it '(MTA) sets title-only this_work from 130, respecting nonfiling chars)' do
        result = this_work12['this_work']
        expect(result).to eq(
                            [{'type'=>'this',
                              'title'=>['Ressreport (Hamburg : Online)'],
                              'title_nonfiling'=>'Kressreport (Hamburg : Online)'}
                            ])
      end
    end
    
    context 'AND 130 contains both $a and $t' do
      it '(MTA) sets title-only this_work from 130, with title_variation subelement' do
        result = this_work13['this_work']
        expect(result).to eq(
                            [{'type'=>'this',
                              'title'=>['Demographic and Health Surveys preliminary report : Dominican Republic.'],
                              'title_variation'=>'Demographic and Health Surveys preliminary report : Republica Dominicana.'}
                            ])
      end
    end
  end

  context 'no 1XX with title subfields, 240, or 130 fields present' do
    it '(MTA) does NOT set this_work' do
      result = this_work14['this_work']
      expect(result).to be_nil
    end
  end
end
