# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::UNC::CallNumber

describe MarcToArgot::Macros::UNC::CallNumber do
  include Util::TrajectRunTest

  context 'WHEN no call number data present' do
    it '(UNC) proceeds gracefully' do
    rec = make_rec
    result = run_traject_on_record('unc', rec)
    expect(result['call_number_schemes']).to be_nil
    expect(result['shelfkey']).to be_nil
    expect(result['reverse_shelfkey']).to be_nil
    expect(result['lcc_callnum_classification']).to be_nil
    end
  end

  describe 'collection_or_subunit?' do
    xit '(UNC) returns true if LDR/07 = c or d' do
      rec = make_rec
      rec.leader[7] = 'c'
         rec << MARC::DataField.new('856', '4', '2',
                                 ['u', 'http://finding-aids.lib.unc.edu/03287/'])
         expect(collection_or_subunit?(rec)).to eq(true)

      rec2 = make_rec
      rec2.leader[7] = 'd'
      expect(collection_or_subunit?(rec2)).to eq(true)
    end
  end
end
