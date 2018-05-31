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
  let(:this_work07) { run_traject_json('unc', 'this_work07', 'mrc') }
  let(:this_work08) { run_traject_json('unc', 'this_work08', 'mrc') }
  let(:this_work09) { run_traject_json('unc', 'this_work09', 'mrc') }
  let(:this_work10) { run_traject_json('unc', 'this_work10', 'mrc') }
  let(:this_work11) { run_traject_json('unc', 'this_work11', 'mrc') }
  let(:this_work12) { run_traject_json('unc', 'this_work12', 'mrc') }
  let(:this_work13) { run_traject_json('unc', 'this_work13', 'mrc') }
  let(:this_work14) { run_traject_json('unc', 'this_work14', 'mrc') }
  let(:this_work15) { run_traject_json('unc', 'this_work15', 'mrc') }

  it '(MTA) sets this_work from 100' do
    result = this_work00_1['this_work']
    expect(result).to eq(
                        [{'type'=>'this',
                          'author'=>'Kuzmin, M. A. (Mikhail Alekseevich), 1872-1936.',
                          'title'=>['Works.', 'Selections.', '1977.']}
                        ])
  end

  it '(MTA) sets this_work from 110' do
    result = this_work00_2['this_work']
    expect(result).to eq(
                        [{'type'=>'this',
                          'author'=>'Pennsylvania.',
                          'title'=>['Laws, etc.', '1825.']}
                        ])
  end

  it '(MTA) sets this_work from 111' do
    result = this_work00_3['this_work']
    expect(result).to eq(
                        [{'type'=>'this',
                          'author'=>'International Congress of Human Sciences in Asia and North Africa (30th : 1976 : Mexico City, Mexico).',
                          'title'=>['Expansión hispanoamericana en Asia.', 'English.']}
                        ])
  end

  it '(MTA) sets this_work from 100 + 240i1=0, with relator term in 100' do
    result = this_work01['this_work']
    expect(result).to eq(
                        [{'type'=>'this',
                          'author'=>'Landis, Thomas D.',
                          'title'=>['Container tree nursery manual.', 'Spanish']}
                        ])
  end

  it '(MTA) sets this_work from 100 + 240i1=1' do
    result = this_work02['this_work']
    expect(result).to eq(
                        [{'type'=>'this',
                          'author'=>'Camus, Albert, 1913-1960.',
                          'title'=>['Étranger.', 'English']}
                        ])
  end

  it '(MTA) sets this_work from 100 + 240 with non-filing characters' do
    result = this_work03['this_work']
    expect(result).to eq(
                        [{'type'=>'this',
                          'author'=>'Burton, Robert Wilton, 1848-1917.',
                          'title'=>['Remnant truth'],
                          'title_nonfiling'=>'De remnant truth'}
                        ])
  end

  it '(MTA) sets this_work from 110 (with relator term) + 240' do
    result = this_work04['this_work']
    expect(result).to eq(
                        [{'type'=>'this',
                          'author'=>'El Salvador',
                          'title'=>['Constitución política (1983).', 'English']}
                        ])
  end

  it '(MTA) sets this_work from 111 + 240' do
    result = this_work05['this_work']
    expect(result).to eq(
                        [{'type'=>'this',
                          'author'=>'Consulta Latinoamericana de Iglesia y Sociedad (2nd : 1966 : El Tabo, Chile)',
                          'title'=>['América hoy.', 'English']}
                        ])
  end

  xit '(MTA) sets this_work from 100 + 245 (non-filing characters, $n after $b)' do
    result = this_work06['this_work']
    expect(result).to eq(
                        [{'type'=>'this',
                          'author'=>'Myers, Johnnie Sue.',
                          'title'=>['Gathering place', 'Volume 1'],
                          'title_nonfiling'=>'The gathering place Volume 1'}
                        ])
  end

  xit '(MTA) sets this_work from 100 + 245 (non-filing characters, $n before $b)' do
    result = this_work07['this_work']
    expect(result).to eq(
                        [{'type'=>'this',
                          'author'=>'Robertson, William, 1721-1793.',
                          'title'=>['History of America.', 'Books IX and X'],
                          'title_nonfiling'=>'The history of America. Books IX and X'}
                        ])
  end

  xit '(MTA) sets this_work from 100 + 245 (title proper from $a only, no non-filing chars)' do
    result = this_work08['this_work']
    expect(result).to eq(
                        [{'type'=>'this',
                          'author'=>'Boman, Patrick, 1948-',
                          'title'=>['Thé de boeuf, radis de cheval']}
                        ])
  end

  xit '(MTA) sets this_work from 110 + 245 (title proper from $a, n, p; non-filing chars)' do
    result = this_work09['this_work']
    expect(result).to eq(
                        [{'type'=>'this',
                          'author'=>'United States. Congress. Senate. Committee on Commerce. Subcommittee on the Environment.',
                          'title'=>['Toxic Substances Control Act of 1971 and amendment.', 'Part 3,', 'Appendix'],
                          'title_nonfiling'=>'The Toxic Substances Control Act of 1971 and amendment. Part 3, Appendix'}
                        ])
  end

  xit '(MTA) sets this_work from 111 + 245 (title proper from $a, n; non-filing chars)' do
    result = this_work10['this_work']
    expect(result).to eq(
                        [{'type'=>'this',
                          'author'=>'International Congress of Prehistoric and Protohistoric Sciences (14th : 2001 : Université de Liège)',
                          'title'=>['Problème de l\'étain à l\'origine de la métallurgie.', 'Section 11'],
                          'title_nonfiling'=>'Le problème de l\'étain à l\'origine de la métallurgie. Section 11'}
                        ])
  end

    it '(MTA) sets this_work from 130 (no nonfiling chars)' do
    result = this_work11['this_work']
    expect(result).to eq(
                        [{'type'=>'this',
                          'title'=>['Bible.', 'New Testament.', 'Latin.', 'Vulgate.', '1541.']}
                        ])
    end

    it '(MTA) sets this_work from 130 (nonfiling chars)' do
      result = this_work12['this_work']
      expect(result).to eq(
                          [{'type'=>'this',
                            'title'=>['Ressreport (Hamburg : Online)'],
                            'title_nonfiling'=>'Kressreport (Hamburg : Online)'}
                          ])
    end

    it '(MTA) sets this_work from 130 ($a and $t present)' do
      result = this_work13['this_work']
      expect(result).to eq(
                          [{'type'=>'this',
                            'title'=>['Demographic and Health Surveys preliminary report : Dominican Republic.'],
                            'title_variation'=>'Demographic and Health Surveys preliminary report : Republica Dominicana.'}
                          ])
    end

    it '(MTA) sets this_work from 245 (no non-filing chars)' do
      result = this_work14['this_work']
      expect(result).to eq(
                          [{'type'=>'this',
                            'title'=>['A&E Classroom.', 'The Class of the 20th Century - 1963-1968']}
                          ])
    end

    it '(MTA) sets this_work from 245 (non-filing chars)' do
      result = this_work15['this_work']
      expect(result).to eq(
                          [{'type'=>'this',
                            'title'=>['Young singer.', 'Soprano'],
                            'title_nonfiling'=>'The Young singer. Soprano'}
                          ])
    end
end
