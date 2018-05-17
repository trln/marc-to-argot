# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:series) { run_traject_json('unc', 'series_statement', 'mrc') }

  xit '(MTA) sets series_statement' do
    result = series['series_statement']
    expect(result).to eq(
                        [{'value'=>'Records of ante-bellum southern plantations from the Revolution through the Civil War. Series J, Selections from the Southern Historical Collection, Manuscript Department, Library of the University of North Carolina at Chapel Hill. Part 7, Alabama ; reel 7:pos.3'},
                         {'value'=>'The Creole language library, 0920-9026 ; v. 47',
                          'other_ids'=>['1234567', 'cd09876'],
                          'issn'=>['0920-9026']},
                         {'value'=>'Miscellaneous publication, 0097-0212 ; no. 60 (S21.A46)',
                          'label'=>'<1929-1948>',
                          'issn'=>['0097-0212']},
                         {'value'=>'List / Office of Governmental and Public Affairs ; no. 11 (Z5075.U5U548)',
                          'label'=>'<1978-1980>'},
                         {'value'=>'List / Office of Communications ; no. 11',
                          'label'=>'<1993->'},
                         {'value'=>'Statistics = Statistiques, 1609-6827 (online) 1023-8875 (print) ; v. 1',
                          'issn'=>['1609-6827', '1023-8875']},
                         {'value'=>'Memoirs of the Geological Survey of India ; v. 123 (QE295.A4) = Bhāratīya Bhūvijñānika Sarvekshaṇa ke saṃsmaraṇa ; khaṇḍa 123'}
                        ]
                      )
  end
end
