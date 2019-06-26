# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::UNC::DummyItems

describe MarcToArgot::Macros::UNC::DummyItems do
  include Util::TrajectRunTest

  context 'WHEN there are no unsuppressed item records on non-e-bib' do
    context 'BUT there is an order record on the bib' do
      context 'AND order record is unsuppressed' do
        context 'AND order status code is z (cancelled)' do
          it '(UNC) creates dummy item using fake \'unknown\' location' do
            rec = make_rec
            rec << MARC::DataField.new('999', '9', '4',
                                       ['f', 'dd'],
                                       ['b', '-'],
                                       ['g', 'z'])
            result = run_traject_on_record('unc', rec)['items'][0]
            expect(result).to include("\"loc_n\":\"unknown\"")
          end
        end
        context 'AND when order status code is NOT z (cancelled)' do
          it '(UNC) creates dummy item with location and On Order status' do
            rec = make_rec
            rec << MARC::DataField.new('999', '9', '4',
                                       ['f', 'dd'],
                                       ['b', '-'],
                                       ['g', 'a'])
            result = run_traject_on_record('unc', rec)['items'][0]
            expect(result).to(
              include("\"status\":\"On Order\"")
            )
            expect(result).to(
              include("\"loc_b\":\"dd\"")
            )
            expect(result).to(
              include("\"loc_n\":\"dd\"")
            )
          end
        end
      end
      context 'AND order record is suppressed' do
      it '(UNC) creates dummy item using fake \'unknown\' location' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '4',
                                     ['f', 'dd'],
                                     ['b', 'n'],
                                     ['g', '-'])
          result = run_traject_on_record('unc', rec)['items'][0]
          expect(result).to include("\"loc_n\":\"unknown\"")
        end
      end
    end

    context 'AND there are NO usable attached records present' do
      it '(UNC) creates dummy item using fake \'unknown\' location' do
          rec = make_rec
          result = run_traject_on_record('unc', rec)['items'][0]
          expect(result).to include("\"loc_n\":\"unknown\"")
        end
    end

  end
end
