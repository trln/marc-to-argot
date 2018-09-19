# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:included_work) { run_traject_json('unc', 'included_work', 'mrc') }
  let(:included_work1) { run_traject_json('unc', 'included_work1', 'mrc') }
  
  it '(MTA) sets included_work' do
    result = included_work['included_work']
    expect(result).to eq(
                        [{'type'=>'included',
                          'author'=>'Saint-SaÃ«ns, Camille, 1835-1921.',
                          'title'=>['Quartets,', 'violins (2), viola, cello,', 'no. 2, op. 153,', 'G major']},
                         {'type'=>'included',
                          'author'=>'Schwenkel, Christina.',
                          'title'=>['Architecture and dwelling in the \'war of destruction\' in Vietnam.']},
                         {'type'=>'included',
                          'label'=>'Facsimile of',
                          'author'=>'Ferrini, Vincent, 1913-2007.',
                          'title'=>['Tidal wave : poems of the great strikes.', '1945', '(New York : Great-Concord Publishers)']},
                         {'type'=>'included',
                          'label'=>'Tome 1, volume 1: Contains',
                          'author'=>'Plotinus.',
                          'title'=>['Peri tou kalou.', 'French', '(Achard and Narbonne)']},
                         {'type'=>'included',
                          'author'=>'Name, Author, (Test name), 1944-.',
                          'title'=>['Test title.']},
                         {'type'=>'included',
                          'author'=>'Kungliga Biblioteket (Sweden).',
                          'title'=>['Manuscript.', 'KB787a.', 'Church Slavic.', '1966.']},
                         {'type'=>'included',
                          'author'=>'United States. Congress (94th, 2nd session : 1976).',
                          'title'=>['Memorial services held in the House of Representatives and Senate of the United States, together with remarks presented in eulogy of Jerry L. Litton, late a Representative from Missouri.', '197.']},
                         {'type'=>'included',
                          'author'=>'North Carolina. Building Code Council.',
                          'title'=>['North Carolina state building code.', '1,', 'General construction.', '11X,', 'Making buildings and facilities accessible to and usable by the physically handicapped.']},
                         {'type'=>'included',
                          'author'=>'Germany (East).',
                          'title'=>['Treaties, etc.', 'Germany (West),', '1990 May 18.', '1990.']},
                         {'type'=>'included',
                          'author'=>'CafÃ© Tacuba (Musical group)',
                          'title'=>['12/12']},
                         {'type'=>'included',
                          'author'=>'Great Central Fair for the U.S. Sanitary Commission (1864 : Philadelphia, Pa.). Committee on Public Charities and Benevolent Institutions.',
                          'title'=>['Philadelphia [blank] 1864. 619 Walnut Street. To [blank] ...']},
                         {'type'=>'included',
                          'author'=>'Deutsch Foundation Conference (1930 : University of Chicago).',
                          'title'=>['Care of the aged.', '2000,', '1972.', 'Reprint.'],
                          'issn'=>'1234-1234'},
                         {'type'=>'included',
                          'title'=>['Cahiers de civilisation mÃ©diÃ©vale.', 'Bibliographie.'],
                          'issn'=>'0240-8678'},
                         {'type'=>'included',
                          'title'=>['Jane Pickering\'s lute book.', 'arr.'],
                          'title_variation'=>'Drewries Accord\'s;'},
                         {'type'=>'included',
                          'label'=>'Contains',
                          'title'=>['Magnificent Ambersons (Motion picture).', 'Spanish.']},
                         {'type'=>'included',
                          'label'=>'Contains',
                          'title'=>['Magnificent Ambersons (Motion picture).', 'English.'],
                          'title_nonfiling'=>'The magnificent Ambersons (Motion picture). English.'},
                         {'type'=>'included',
                          'label'=>'Guide: Based on',
                          'title'=>['Deutsche Geschichte.', 'Band 6.']},
                         {'type'=>'included',
                          'title'=>['English pilot.', 'The fourth book : describing the West India navigation, from Hudson\'s-Bay to the river Amazones ...'],
                          'title_nonfiling'=>'The English pilot. The fourth book : describing the West India navigation, from Hudson\'s-Bay to the river Amazones ...'},
                         {'type'=>'included',
                          'title'=>['Industrial sales management game', '5.']},
                         {'type'=>'included',
                          'author'=>'Masson, VeNeta.',
                          'title'=>['Rehab at the Florida Avenue Grill.'],
                          'details'=>'Washington, DC : Sage Femme Press, 1999',
                          'isbn'=>['0967368804'],
                          'other_ids'=>['99090707', '43689896']},
                         {'type'=>'included',
                          'author'=>'Masson, VeNeta.',
                          'title'=>['Rehab at the Florida Avenue Grill.'],
                          'isbn'=>['0967368804'],
                          'other_ids'=>['99090707', '43689896'],
                          'display'=>'false'},
                         {'type'=>'included',
                          'label'=>'Contains',
                          'title'=>['Sports illustrated.'],
                          'details'=>'Dean Smith commemorative issue (Feb. 26, 2015)',
                          'other_ids'=>['1766364']},
                         {'type'=>'included',
                          'title'=>['Bulletin', '(North Carolina Agricultural Experiment Station)'],
                          'title_variation'=>'1991 NC Agricultural Experiment Station Bulletin',
                          'other_ids'=>['1421220']},
                         {'type'=>'included',
                          'title'=>['Bellevue literary review :'],
                          'issn'=>'1537-5048',
                          'other_ids'=>['2001211888', '48166959'],
                          'display'=>'false'}
                        ]
                      )
  end

    xit '(MTA) sets included_work from 880s' do
    result = included_work1['included_work']
    expect(result).to include(
                        {'type'=>'included',
                          'author'=>'劉卲, active 3rd century.',
                          'title'=>['人物志.', '1974.'],
                          'lang'=>'cjk'
                        }
                      )
  end
end
