# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::Shared::Helpers
include MarcToArgot::Macros::Shared::SubjectGenre
include MarcToArgot::Macros::UNC::LocalSubjectGenre

describe MarcToArgot::Macros::UNC::LocalSubjectGenre do
  include Util
  describe 'mrc_genre_fields' do
    context 'LDR/06 = g' do
      context 'AND 690 with |2 present' do
        it '(UNC) sets $a of 690 with |2local as genre_unc_mrc' do
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
      context 'AND 690 with |2 NOT present' do
        it '(UNC) does not set genre_unc_mrc' do
          rec = make_rec
          rec.leader[6] = 'g'
          result = run_traject_on_record('unc', rec)['genre_unc_mrc']
          expect(result).to be_nil
        end
      end
    end
    context 'LDR/06 != g' do
      it '(UNC) does not set genre_unc_mrc' do
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

  describe 'local_geog_fields' do
    context '691 field(s) present' do
      it '(MTA) sets subject_heading values from 691' do
        rec = make_rec
        rec << MARC::DataField.new('691', ' ', ' ',
                                   ['a', 'North Carolina'],
                                   ['z', 'Eastern section'],
                                   ['x', 'Agriculture'])
        result = run_traject_on_record('unc', rec)['subject_headings'][0][:value]
        expect(result).to eq('North Carolina -- Eastern section -- Agriculture')
      end

      it '(UNC) sets subject_geographic values from 691' do
        rec = make_rec
        rec << MARC::DataField.new('691', ' ', ' ',
                                   ['a', 'North Carolina'],
                                   ['z', 'Eastern section'],
                                   ['x', 'Agriculture'])
        result = run_traject_on_record('unc', rec)['subject_geographic']
        expect(result).to eq(['Eastern section', 'North Carolina'])
      end

      context 'AND 651 field(z) present' do
        it '(UNC) sets subject_geographic values from 651 and 691' do
          rec = make_rec
          rec << MARC::DataField.new('651', ' ', ' ',
                                     ['a', 'North Carolina'],
                                     ['z', 'Durham County'],
                                     ['x', 'Agriculture'])
          rec << MARC::DataField.new('691', ' ', ' ',
                                     ['a', 'North Carolina'],
                                     ['z', 'Eastern section'],
                                     ['x', 'Agriculture'])
          result = run_traject_on_record('unc', rec)['subject_geographic'].sort
          expect(result).to eq(['Durham County', 'Eastern section', 'North Carolina'])
        end
        
      end
    end
  end
end
