# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:series_work) { run_traject_json('unc', 'series_work', 'mrc') }
  let(:series_work01) { run_traject_json('unc', 'series_work01', 'mrc') }
  
  xit '(MTA) sets series_work' do
    result = series_work['series_work']
    expect(result).to eq(
                        [  {'type'=>'series',
                            'author'=>'Shakespeare, William, 1564-1616.',
                            'title'=>'Works.||Selections.||1880',
                            'details'=>'no. 23-24.'},
                           {'type'=>'series',
                            'author'=>'Ellington, Duke, 1899-1974.',
                            'title'=>'Private collection',
                            'details'=>'v. 6'},
                           {'type'=>'series',
                            'author'=>'Field, John, 1782-1837.',
                            'title'=>'Concertos,||piano, orchestra.||Chandos Records (Firm)',
                            'details'=>'v. 4.'},
                           {'type'=>'series',
                            'title'=>'Canadian Mathematical Society.',
                            'issn'=>'1613-5237'},
                           {'type'=>'series',
                            'title'=>'Canadian Mathematical Society.',
                            'issn'=>'1613-5237'},
                           {'type'=>'series',
                            'author'=>'World Conference on Faith and Order. Continuation Committee.',
                            'title'=>'Pamphlets published by the Continuation Committee',
                            'details'=>'33-103.'},
                           {'type'=>'series',
                            'author'=>'Going Romance (Conference).',
                            'title'=>'Romance languages and linguistic theory',
                            'details'=>'v. 9.',
                            'issn'=>'1574-552X'},
                           {'type'=>'series',
                            'title'=>'Policy, research, and external affairs working papers',
                            'details'=>'WPS 702.'},
                           {'type'=>'series',
                            'title'=>'Handbook of Environmental Chemistry,',
                            'title_nonfiling'=>'The Handbook of Environmental Chemistry,',
                            'issn'=>'1867-979X',
                            'details'=>'65.'},
                           {'type'=>'series',
                            'label'=>'1920-1922',
                            'title'=>'House document (United States. Congress. House)'},
                           {'type'=>'series',
                            'label'=>'1871, 1886',
                            'title'=>'Ex. doc. (United States. Congress. House)'},
                           {'type'=>'series',
                            'label'=>'1922-1931',
                            'title'=>'Department of State publication.'},
                           {'type'=>'series',
                            'title'=>'Biblical seminar',
                            'title_variation'=>'Lost coin.',
                            'details'=>'86.'},
                           {'type'=>'series',
                            'label'=>'Some volumes in main series',
                            'title'=>'Vital and health statistics.||Series 22, Data from the national vital statistics system',
                            'issn'=>'0083-2049',
                            'other_ids'=>['66060347', '1768533']},
                           {'type'=>'series',
                            'author'=>'Kazan, Russia (City) Universitet.',
                            'title'=>'Uchenye zapiski,',
                            'details'=>'t. 128, kn. 4; t. 129, kn. 7.'},
                           {'type'=>'series',
                            'author'=>'Food and Agriculture Organization of the United Nations. Committee on Commodity Problems.',
                            'title'=>'[Document] CCP',
                            'issn'=>'0426-7877',
                            'other_ids'=>['65079781', '1380035'],
                            'display'=>'false'},
                           {'type'=>'subseries',
                            'author'=>'Cullowhee Normal and Industrial School (Cullowhee, N.C.).',
                            'title'=>'Catalogue number.'},
                           {'type'=>'subseries',
                            'author'=>'Cullowhee Normal and Industrial School (Cullowhee, N.C.).',
                            'title'=>'Summer school number.'},
                           {'type'=>'subseries',
                            'author'=>'France. Service des études économiques et financières.',
                            'title'=>'Études de comptabilité nationale',
                            'other_ids'=>['6313705'],
                            'display'=>'false'}
                        ]
                      )
  end

  xit '(MTA) sets series_work' do
    result = series_work['series_work']
    expect(result).to eq(
                        [{'type'=>'series',
                          'title'=>'Records of ante-bellum southern plantations from the Revolution through the Civil War.||Series J,||Selections from the Southern Historical Collection, Manuscripts Department, Library of the University of North Carolina at Chapel Hill.||Part 3,||South Carolina',
                          'details'=>'reel 1'},
                         {'type'=>'series',
                          'title'=>'Stewart dynasty in Scotland',
                          'title_nonfiling'=>'The Stewart dynasty in Scotland'},
                         {'type'=>'series',
                          'title'=>'Companions to contemporary German culture',
                          'issn'=>'2193-9659',
                          'details'=>'v. 3'}
                        ]
                      )
  end
end


