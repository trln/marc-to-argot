# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::Shared::Helpers
include MarcToArgot::Macros::Shared::SubjectGenre
include MarcToArgot::Macros::UNC::LocalSubjectGenre

describe MarcToArgot::Macros::UNC::LocalSubjectGenre do
  include Util
  context 'LDR/06 = g' do
    it '(MTA) sets $a of 690 with |2local as genre_unc_mrc' do
      rec = make_rec
      rec.leader[6] = 'g'
      rec << MARC::DataField.new('690', ' ', '7',
                                 ['a', 'Politics & Government'],
                                 ['2', 'local'])
      rec << MARC::DataField.new('690', ' ', '7',
                                 ['a', 'Genocide'],
                                 ['z', 'Cambodia'],
                                 ['2', 'local'])
      result = run_traject_on_record('unc', rec)['genre_unc_mrc']
      expect(result).to eq(['Politics & Government', 'Genocide'])
    end
  end
  context 'LDR/06 != g' do
    it '(MTA) does not set genre_unc_mrc' do
      rec = make_rec
      rec << MARC::DataField.new('690', ' ', '7',
                                 ['a', 'Politics & Government'],
                                 ['2', 'local'])
      rec << MARC::DataField.new('690', ' ', '7',
                                 ['a', 'Genocide'],
                                 ['z', 'Cambodia'],
                                 ['2', 'local'])
      result = run_traject_on_record('unc', rec)['genre_unc_mrc']
      expect(result).to be_nil
    end
  end  

end
