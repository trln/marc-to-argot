# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::Shared::Helpers
include MarcToArgot::Macros::Shared::OriginPlace

describe MarcToArgot::Macros::Shared::OriginPlace do
  include Util

  context '752 field present' do
    it '(MTA) extracts origin_place_search from 752' do
      rec1 = make_rec
      rec1 << MARC::DataField.new('752', ' ', ' ',
                                 ['a', 'United States'],
                                 ['b', 'North Carolina'],
                                 ['c', 'Wake. '],
                                 ['d', 'Raleigh'])
      result = run_traject_on_record('unc', rec1)['origin_place_search']
      expect(result).to eq([{
                              'value' => 'United States--North Carolina--Wake--Raleigh'
                            }])
    end

    it '(MTA) extracts origin_place_facet from 752' do
      rec = make_rec
      rec << MARC::DataField.new('752', ' ', ' ',
                                 ['a', 'United States'],
                                 ['b', 'North Carolina'],
                                 ['c', 'Wake. '],
                                 ['d', 'Raleigh'])
      result = run_traject_on_record('unc', rec)['origin_place_facet']
      expect(result).to eq(['United States',
                            'North Carolina',
                            'Wake',
                            'Raleigh'],
                          )
    end

    
    it '(MTA) extracts facetable Washington, D.C. and New York values' do
      rec = make_rec
      rec << MARC::DataField.new('752', ' ', ' ',
                                 ['a', 'United States'],
                                 ['b', 'New York'],
                                 ['c', 'New York'],
                                 ['d', 'New York'])
      rec << MARC::DataField.new('752', ' ', ' ',
                                 ['a', 'United States'],
                                 ['b', 'District of Columbia'],
                                 ['d', 'Washington.'])
      result = run_traject_on_record('unc', rec)['origin_place_facet']
      expect(result.sort).to eq(['United States',
                                 'New York (State)',
                                 'New York County (N.Y.)',
                                 'New York (N.Y.)',
                                 'District of Columbia',
                                 'Washington (D.C.)'].sort
                               )
    end
  end

  context '752-linked 880 field present' do
    it '(MTA) extracts origin_place_search from 880 and classifies script' do
      rec = make_rec
      rec << MARC::DataField.new('752', ' ', ' ',
                                 ['6', '880-06'],
                                 ['a', 'Russia (Federation)'],
                                 ['d', 'Romanization.']
                                )
      rec << MARC::DataField.new('752', ' ', ' ',
                                 ['a', 'Russia (Federation)'],
                                 ['d', 'Romanization.']
                                )
      rec << MARC::DataField.new('880', ' ', ' ',
                                 ['6', '752-06/(N'],
                                 ['a', 'Russia (Federation)'],
                                 ['d', 'Владикавказ.']
                                )
      result = run_traject_on_record('unc', rec)['origin_place_search']
      expect(result).to eq([{'value' => 'Russia (Federation)--Romanization'},
                            {'value' => 'Russia (Federation)--Владикавказ',
                             'lang' => 'rus'}
                           ])
    end
  end
  
  context '752 NOT present' do
    it '(MTA) does not set origin_place_facet' do
      rec = make_rec
      result = run_traject_on_record('unc', rec)['origin_place_facet']
      expect(result).to be_nil
    end

    it '(MTA) does not set origin_place_search' do
      rec = make_rec
      result = run_traject_on_record('unc', rec)['origin_place_search']
      expect(result).to be_nil
    end
  end

  describe 'get_and_clean_752s' do
    it 'generates cleaned array of 752 fields from record' do
      rec = make_rec
      rec << MARC::DataField.new('752', ' ', ' ',
                                 ['a', 'United States'],
                                 ['b', 'North Carolina'],
                                 ['c', 'Wake. '],
                                 ['d', 'Raleigh'])
      rec << MARC::DataField.new('752', ' ', ' ',
                                 ['a', 'Great  Britain'],
                                 ['b', 'England'],
                                 ['d', 'London'])

      result = get_and_clean_752s(rec)
      result = result.map { |f| f.to_s }.sort
      expect(result).to eq([ '752    $a Great Britain $b England $d London ',
                             '752    $a United States $b North Carolina $c Wake $d Raleigh '
                           ]
                          )
    end
  end

  describe 'get_searchable_752s' do
    it 'returns array of searchable hashes from 752 fields of record' do
      rec = make_rec
      rec << MARC::DataField.new('752', ' ', ' ',
                                 ['a', 'Great  Britain'],
                                 ['b', 'England'],
                                 ['d', 'London'])

      result = get_searchable_752s(rec)
      expect(result).to eq([ {'value' => 'Great Britain--England--London'} ])
    end
  end
  
  describe 'get_searchable_places' do
    it 'returns array of searchable place hashes from all relevant fields of record' do
      rec = make_rec
      rec << MARC::DataField.new('752', ' ', ' ',
                                 ['a', 'Great  Britain'],
                                 ['b', 'England'],
                                 ['d', 'London'])

      result = get_searchable_places(rec)
      expect(result).to eq([ {'value' => 'Great Britain--England--London'} ])
    end
  end
end
