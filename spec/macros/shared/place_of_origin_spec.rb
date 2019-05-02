# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::Shared::Helpers
include MarcToArgot::Macros::Shared::PlaceOfOrigin

describe MarcToArgot::Macros::Shared::PlaceOfOrigin do
  include Util

  #=752  \\$aUnited States$bNew York$dNew York.
  #=752  \\$aUnited States$bDistrict of Columbia$dWashington.
  context '752 field present' do
    it '(MTA) extracts place_of_origin from 752' do
      rec = make_rec
      rec << MARC::DataField.new('752', ' ', ' ',
                                 ['a', 'United States'],
                                 ['b', 'North Carolina'],
                                 ['c', 'Wake. '],
                                 ['d', 'Raleigh'])
      result = run_traject_on_record('unc', rec)['place_of_origin']
      expect(result).to eq([{
                             'facet' => ['United States', 'North Carolina', 'Wake', 'Raleigh'],
                             'search' => ['United States--North Carolina--Wake--Raleigh']
                           }])
    end
    it '(MTA) extracts facetable Washington, D.C.' do
      rec = make_rec
      rec << MARC::DataField.new('752', ' ', ' ',
                                 ['a', 'United States'],
                                 ['b', 'District of Columbia'],
                                 ['d', 'Washington.'])
      result = run_traject_on_record('unc', rec)['place_of_origin']
      expect(result).to eq([{
                             'facet' => ['United States', 'District of Columbia', 'Washington (D.C.)'],
                             'search' => ['United States--District of Columbia--Washington']
                           }])
    end
    it '(MTA) extracts facetable New York (state) and New York (city) values' do
      rec = make_rec
      rec << MARC::DataField.new('752', ' ', ' ',
                                 ['a', 'United States'],
                                 ['b', 'New York'],
                                 ['c', 'New York'],
                                 ['d', 'New York'])
      result = run_traject_on_record('unc', rec)['place_of_origin']
      expect(result).to eq([{
                             'facet' => ['United States', 'New York (State)', 'New York County (N.Y.)', 'New York (N.Y.)'],
                             'search' => ['United States--New York--New York--New York']
                           }])
    end
    #multiple 752 in one field:
    # =752  \\$aUnited States$bMassachusetts$dBoston.
    # =752  \\$aUnited States$bNew York$dNew York.
    # =752  \\$aUnited States$bMassachusetts$dCambridge.

  end
end
