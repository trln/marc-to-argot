# coding: utf-8
require 'spec_helper'
describe MarcToArgot::Macros::Shared::CreatorMain do
  include Util::TrajectRunTest
  
  context 'record has 100 field' do
    it '(MTA) sets creator_main from 100' do
      rec = make_rec
      rec << MARC::DataField.new('100', ' ', '1', ['a', 'Doe, Jane,'], ['d', '1970-'])
      rt = run_traject_on_record('unc', rec)['creator_main']
      expect(rt).to eq(['Doe, Jane, 1970-'])
    end

    context '100 has redundant $e and $4' do
      it '(MTA) uses names macro relator handling logic to deduplicate' do
        rec = make_rec
        rec << MARC::DataField.new('100', ' ', '1', ['a', 'Doe, Jane,'],
                                   ['e', 'editor'], ['4', 'edt'])
        rt = run_traject_on_record('unc', rec)['creator_main']
        expect(rt).to eq(['Doe, Jane, editor'])
      end
    end

    context '100 has linked 880 field' do
      it '(MTA) shows vernacular first' do
        rec = make_rec
        rec << MARC::DataField.new('100', ' ', '1',
                                   ['6', '880-01'],
                                   ['a', 'Murād, Saʻīd'],
                                   ['c', '(Musician)'],
                                   ['4', 'cmp'], ['4', 'prf'])
        rec << MARC::DataField.new('880', ' ', '1',
                                   ['6', '100-01/r'],
                                   ['a', 'مراد، سعيد.'])
        rt = run_traject_on_record('unc', rec)['creator_main']
        expect(rt).to eq(['مراد، سعيد / Murād, Saʻīd (Musician), composer, performer'])
      end
    end
  end

  context 'record has no 100, 110, or 111 field' do
    it '(MTA) does not fall over' do
      rec = make_rec
      rt = run_traject_on_record('unc', rec)['creator_main']
      expect(rt).to be_nil
    end
  end
  

end
