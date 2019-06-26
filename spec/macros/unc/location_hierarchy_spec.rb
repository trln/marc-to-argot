# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::UNC::LocationHierarchy

describe MarcToArgot::Macros::UNC::LocationHierarchy do
  include Util::TrajectRunTest

  describe 'setting bib-level location_hierarchy values from UNC item records' do
    context 'WHEN bib record has item for valid print location' do
      it '(UNC) sets bib level location_hierarchy for print location' do
        rec = make_rec
        rec << MARC::DataField.new('999', '9', '1',
                                   ['l', 'ggda']
                                  )
        argot = run_traject_on_record('unc', rec)
        expect(argot['location_hierarchy']).to eq(['unc', 'unc:uncrarn', 'unc:uncwil', 'unc:uncwil:uncwilrbc'])
      end

      context 'AND it also has an unsuppressed e-resource item' do
        it '(UNC) sets bib level location_hierarchy for print location only' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['i', 'i1688265'],
                                     ['l', 'dcpf'],
                                     ['v', 'Bd.2'])
          rec << MARC::DataField.new('999', '9', '1',
                                     ['i', 'i1688265'],
                                     ['l', 'erra'],
                                     ['v', 'Bd.2'])

          result = run_traject_on_record('unc', rec)['location_hierarchy']
          expect(result).to(
            eq(['unc', 'unc:uncdavy', 'unc:uncdavy:uncdavdoc'])
          )
        end
      end
    end
  end

  describe 'setting bib-level location hierarchy values from UNC holdings records' do
    context 'WHEN there are no items with locations on the bib record' do
      context 'AND there is a holdings record with a location' do
        it '(UNC) sets bib level location_hierarchy from holdings locations' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '2',
                                     ['a', 'c5151797'],
                                     ['b', 'dcpf'],
                                     ['c', '0'])
          rec << MARC::DataField.new('999', '9', '3',
                                     ['0', 'c5151797'],
                                     ['2', '852'],
                                     ['3', 'c'],
                                     ['h', 'A 7.1:'])
          result = run_traject_on_record('unc', rec)['location_hierarchy']
          expect(result).to(
            eq(['unc', 'unc:uncdavy', 'unc:uncdavy:uncdavdoc'])
          )
        end
      end
    end
  end

  describe 'bib-level location hierarchy effect of dummy records created from orders' do
    context 'WHEN the order record has a location code' do
      it '(UNC) sets location_hierarchy from order location code' do
        rec = make_rec
        rec << MARC::DataField.new('999', '9', '4',
                                   ['f', 'dd'],
                                   ['b', '-'],
                                   ['g', '-'])
        result = run_traject_on_record('unc', rec)['location_hierarchy']
          expect(result).to(
            eq(['unc', 'unc:uncdavy'])
          )
      end
    end
  end

  describe 'bib-level location hierarchy effect of dummy records created from nothing' do
    context 'WHEN the \'unknown\' location code is set in a dummy record' do
      it '(UNC) does NOT populate location_hierarchy from unknown' do
        rec = make_rec
        result = run_traject_on_record('unc', rec)['location_hierarchy']
        expect(result).to be_nil
      end
    end
  end
end
