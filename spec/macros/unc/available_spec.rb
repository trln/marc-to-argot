# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::UNC::Available

describe MarcToArgot::Macros::UNC::Available do
  include Util::TrajectRunTest

  describe 'setting (bib level) availability values from UNC items -- At the bib level, all item statuses are collapsed into one binary (Available/Not Available)' do
    context 'WHEN there is one item record attached to bib' do

      rules = {
        '!' => 'Not Available',
        '$' => 'Not Available',
        '-' => 'Available',
        'a' => 'Available',
        'b' => 'Not Available',
        'c' => 'Not Available',
        'd' => 'Not Available',
        'e' => 'Not Available',
        'f' => 'Not Available',
        'g' => 'Available',
        'h' => 'Not Available',
        'j' => 'Available',
        'k' => 'Not Available',
        'm' => 'Not Available',
        'n' => 'Not Available',
        'o' => 'Available',
        'p' => 'Not Available',
        'r' => 'Not Available',
        's' => 'Not Available',
        't' => 'Not Available',
        'u' => 'Not Available',
        'v' => 'Not Available',
        'w' => 'Not Available',
        'z' => 'Not Available',        
      }

      rules.each do |code, available|
        context "AND item status = #{code}" do
          it "(UNC) (bib level, binary) available = #{available}" do
            rec = make_rec
            rec << MARC::DataField.new('999', '9', '1',
                                       ['s', "#{code}"])
            result = run_traject_on_record('unc', rec)['available']
            case rules[code]
            when 'Available'
              expect(result).to eq('Available'), "with status:#{code}, expected #{available}, got #{result.inspect}"
            when 'Not Available'
              expect(result).to be_nil, "with status:#{code}, expected nil, got #{result.inspect}"
            end
          end
        end
      end

      context "AND item has a due date value (2066-6-6)" do
        it '(UNC) (bib level, binary) available = Not Available' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', '-'],
                                     ['d', '2066-06-06'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to be_nil
        end
      end
    end
  end

  context 'WHEN bib has multiple items attached' do
    context 'AND status codes of the items are: w, m, b, t, o' do
      it '(UNC) (bib level, binary) available = Available' do
        rec = make_rec
        rec << MARC::DataField.new('999', '9', '1',
                                   ['s', 'w'])
        rec << MARC::DataField.new('999', '9', '1',
                                   ['s', 'm'])
        rec << MARC::DataField.new('999', '9', '1',
                                   ['s', 'b'])
        rec << MARC::DataField.new('999', '9', '1',
                                   ['s', 't'])
        rec << MARC::DataField.new('999', '9', '1',
                                   ['s', 'o'])
        argot = run_traject_on_record('unc', rec)
        expect(argot['available']).to eq('Available')
      end
    end

    context 'AND status codes of the items are: w, m, b, t, f' do
      it '(UNC) (bib level, binary) available = Not Available' do
        rec = make_rec
        rec << MARC::DataField.new('999', '9', '1',
                                   ['s', 'w'])
        rec << MARC::DataField.new('999', '9', '1',
                                   ['s', 'm'])
        rec << MARC::DataField.new('999', '9', '1',
                                   ['s', 'b'])
        rec << MARC::DataField.new('999', '9', '1',
                                   ['s', 't'])
        rec << MARC::DataField.new('999', '9', '1',
                                   ['s', 'f'])
        argot = run_traject_on_record('unc', rec)
        expect(argot['available']).to be_nil
      end
    end
  end

  context 'WHEN there are no unsuppressed item records on non-e-bib' do
    context 'BUT there is an order record on the bib' do
      context 'AND order record is unsuppressed' do
        context 'AND order status code is z (cancelled)' do
          it '(UNC) (UNC) (bib level, binary) available = Available' do
            rec = make_rec
            rec << MARC::DataField.new('999', '9', '4',
                                       ['f', 'dd'],
                                       ['b', '-'],
                                       ['g', 'z'])
            result = run_traject_on_record('unc', rec)['available']
            expect(result).to eq('Available')
          end
        end
        context 'AND when order status code is NOT z (cancelled)' do
          it '(UNC) (bib level, binary) available = Not Available' do
            rec = make_rec
            rec << MARC::DataField.new('999', '9', '4',
                                       ['f', 'dd'],
                                       ['b', '-'],
                                       ['g', 'a'])
            result = run_traject_on_record('unc', rec)['available']
            expect(result).to be_nil
          end
        end
      end
    end
  end
  
end

