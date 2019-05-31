# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::Shared::Helpers
include MarcToArgot::Macros::Shared::SubjectGenre
include MarcToArgot::Macros::UNC::LocalSubjectGenre

describe MarcToArgot::Macros::UNC::LocalSubjectGenre do
  include Util
  describe 'mrc_genre_fields' do
    context 'LDR/06 = g' do
      context 'AND 69x with |2uncmrc* present' do
        context 'AND term in 69x is on MRC FF Genre list' do
          it '(UNC) sets $a of 690 with |2uncmrc* as genre_unc_mrc' do
            rec = make_rec
            rec.leader[6] = 'g'
            rec << MARC::DataField.new('690', ' ', '7',
                                       ['a', 'Politics & Government'],
                                       ['2', 'uncmrcsub'])
            rec << MARC::DataField.new('690', ' ', '7',
                                       ['a', 'Genocide '],
                                       ['z', 'Cambodia'],
                                       ['2', 'uncmrcsub'])
            rec << MARC::DataField.new('695', ' ', '7',
                                       ['a', 'British literature Adaptations'],
                                       ['2', 'uncmrcgen'])

            result = run_traject_on_record('unc', rec)['genre_unc_mrc']
            expect(result).to eq(['Politics & Government',
                                  'Genocide',
                                  'British literature Adaptations'])
          end
        end

        context 'AND term in 69x is NOT on MRC FF Genre list' do
          it '(UNC) does not set genre_unc_mrc' do
            rec = make_rec
            rec.leader[6] = 'g'
            # The following is not in mrc_dropdown_genres
            rec << MARC::DataField.new('695', ' ', '7',
                                       ['a', 'Chinese literature Adaptations'],
                                       ['2', 'uncmrcgen'])
            result = run_traject_on_record('unc', rec)['genre_unc_mrc']
            expect(result).to be_nil
          end
        end
      end

      context 'AND 69x with |2uncmrc* NOT present' do
        it '(UNC) does not set genre_unc_mrc' do
          rec = make_rec
          rec.leader[6] = 'g'
            # The following is an MRC term, but also a Wilson term assigned by Wilson
            rec << MARC::DataField.new('690', ' ', '7',
                                       ['a', 'Animal behavior'],
                                       ['2', 'uncwilson'])
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

  describe 'local_genre_fields' do
    context '695 field(s) present' do
      it '(UNC) sets genre_headings values from 695' do
        rec = make_rec
        rec << MARC::DataField.new('695', ' ', '7',
                                   ['a', 'Patents'],
                                   ['2', 'uncert'])
        result = run_traject_on_record('unc', rec)['genre_headings'][0][:value]
        expect(result).to eq('Patents')
      end

      it '(UNC) does NOT set subject_headings values from 695' do
        rec = make_rec
        rec << MARC::DataField.new('695', ' ', '7',
                                   ['a', 'Patents'],
                                   ['2', 'uncert'])
        result = run_traject_on_record('unc', rec)['subject_headings'][0][:value]
        expect(result).to be_nil
      end

     it '(UNC) sets subject_genre values from 695' do
        rec = make_rec
        rec << MARC::DataField.new('695', ' ', '7',
                                   ['a', 'Motion pictures'],
                                   ['v', 'Chinese language'],
                                   ['2', 'uncmrcgen'])
        result = run_traject_on_record('unc', rec)['subject_genre']
        expect(result).to eq(['Motion pictures', 'Chinese language'])
      end

      context 'AND 655 field present' do
        it '(UNC) sets subject_genre values from 655 and 695' do
          rec = make_rec
          rec << MARC::DataField.new('655', ' ', '7',
                                     ['a', 'Documentary films.'],
                                     ['2', 'lcgft'])
          rec << MARC::DataField.new('695', ' ', '7',
                                     ['a', 'Patents'],
                                     ['2', 'uncert'])
          result = run_traject_on_record('unc', rec)['subject_genre'].sort
          expect(result).to eq(['Documentary films', 'Patents'])
        end
      end
    end
  end

  describe 'local_chronological_fields' do
    context '698 field(s) present' do
      it '(MTA) sets subject_heading values from 698' do
        rec = make_rec
        rec << MARC::DataField.new('698', ' ', '7',
                                   ['a', 'Local time period'],
                                   ['2', 'uncert'])
        result = run_traject_on_record('unc', rec)['subject_headings'][0][:value]
        expect(result).to eq('Local time period')
      end

      it '(UNC) sets subject_chronological values from 698' do
        rec = make_rec
        rec << MARC::DataField.new('698', ' ', '7',
                                   ['a', 'Local time period'],
                                   ['2', 'uncmrcgen'])
        result = run_traject_on_record('unc', rec)['subject_chronological']
        expect(result).to eq(['Local time period'])
      end

      context 'AND 648 field present' do
        it '(UNC) sets subject_chronological values from 655 and 695' do
          rec = make_rec
          rec << MARC::DataField.new('648', ' ', '0',
                                     ['a', 'Twentieth century.'])
          rec << MARC::DataField.new('698', ' ', '7',
                                     ['a', 'Local time period'],
                                     ['2', 'uncert'])
          result = run_traject_on_record('unc', rec)['subject_chronological'].sort
          expect(result).to eq(['Local time period', 'Twentieth century'])
        end
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

      it '(UNC) sets subject_geographic values from 691, combining a & z' do
        rec = make_rec
        rec << MARC::DataField.new('691', ' ', ' ',
                                   ['a', 'North Carolina'],
                                   ['z', 'Eastern section'],
                                   ['x', 'Agriculture'])
        result = run_traject_on_record('unc', rec)['subject_geographic']
        expect(result).to eq(['North Carolina -- Eastern section'])
      end

      context 'AND 651 field(s) present' do
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
          expect(result).to eq(['Durham County', 'North Carolina', 'North Carolina -- Eastern section'])
        end
        
      end

      context 'AND 690/5 field(s) with $z present' do
        it '(UNC) sets subject_geographic values from $z of other local fields' do
          rec = make_rec
          rec << MARC::DataField.new('690', ' ', ' ',
                                     ['a', 'Genocide'],
                                     ['z', 'Cambodia'],
                                     ['2', 'uncmrcsub'])
          rec << MARC::DataField.new('695', ' ', ' ',
                                     ['a', 'Foreign films'],
                                     ['z', 'Cambodia'],
                                     ['2', 'uncmrcgen'])
          result = run_traject_on_record('unc', rec)['subject_geographic'].sort
          expect(result).to eq(['Cambodia'])
        end
        
      end
    end
  end
end
