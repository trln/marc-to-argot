# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util
  let(:series) { run_traject_json('unc', 'series_statement', 'mrc') }
  let(:botched_series) { run_traject_json('duke', 'bad-490', 'xml') }

  it '(MTA) sets series_statement' do
    result = series['series_statement']
    expect(result).to eq(
                        [{'value'=>'Records of ante-bellum southern plantations from the Revolution through the Civil War. Series J, Selections from the Southern Historical Collection, Manuscript Department, Library of the University of North Carolina at Chapel Hill. Part 7, Alabama ; reel 7:pos.3'},
                         {'value'=>'The Creole language library, 0920-9026 (print); v. 47',
                          'issn'=>['0920-9026'],
                          'other_ids'=>['1234567', 'cd09876']},
                         {'label'=>'<1929-1948>',
                          'value'=>'Miscellaneous publication, 0097-0212 ; no. 60 (S21.A46)',
                          'issn'=>['0097-0212']},
                         {'label'=>'<1978-1980>',
                          'value'=>'List / Office of Governmental and Public Affairs ; no. 11 (Z5075.U5U548)'},
                         {'label'=>'<1993->',
                          'value'=>'List / Office of Communications ; no. 11'},
                         {'value'=>'Statistics = Statistiques, 1609-6827 (online) 1023-8875 (print) ; v. 1',
                          'issn'=>['1609-6827', '1023-8875']},
                         {'value'=>'Memoirs of the Geological Survey of India ; v. 123 (QE295.A4) = Bhāratīya Bhūvijñānika Sarvekshaṇa ke saṃsmaraṇa ; khaṇḍa 123'}
                        ]
                      )
  end

  it '(MTA) sets series_statement from linked 880 field' do
    rec = make_rec
    rec << MARC::DataField.new('490', '1', ' ',
                               ['6', '880-04'],
                               ['a', 'Seri︠i︡a "Biblioteka Samizdata" ;'],
                               ['v', 'no. 2'])
    rec << MARC::DataField.new('880', '1', ' ',
                               ['6', '490-04/(N'],
                               ['a', 'Серия "Библиотека Самиздата" ;'],
                               ['v', 'no. 2'])
    argot = run_traject_on_record('unc', rec)
    result = argot['series_statement']
    expect(result).to eq([
                           { 'value' => 'Seri︠i︡a "Biblioteka Samizdata" ; no. 2' },
                           { 'value' => 'Серия "Библиотека Самиздата" ; no. 2',
                             'lang' => 'rus' }
                         ])
  end

  it '(MTA) sets series_statement from non-Roman 490 field' do
    rec = make_rec
    rec << MARC::DataField.new('490', '1', ' ',
                               ['a', 'Серия "Библиотека Самиздата" ;'],
                               ['v', 'no. 2'])
    argot = run_traject_on_record('unc', rec)
    result = argot['series_statement']
    expect(result).to eq([
                           { 'value' => 'Серия "Библиотека Самиздата" ; no. 2',
                             'lang' => 'rus' }
                         ])
  end

  it 'record processing does not fail if the subfield is present but empty' do
    result = botched_series['series_statement']
    expect(result).to eq([{ 'issn' => [nil], 'value' => ', ' }])
  end
end
