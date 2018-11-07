# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::Shared::StatementOfResponsibility do
  include Util
  let(:statement_of_responsibility) { run_traject_json('duke', 'statement_of_responsibility', 'mrc') }
  let(:statement_of_responsibility_vern1) { run_traject_json('unc', 'statement_of_responsibility_vern1', 'mrc') }

  it '(MTA) sets statement_of_responsibility' do
    result = statement_of_responsibility['statement_of_responsibility']
    expect(result).to eq(
                        [{"value"=>"pod redakt︠s︡īeĭ Grafini Uvarovoĭ."},
                         {"value"=>"под редакціей Графини Уваровой.", "lang"=>"rus"}]
                      )
  end

  it '(MTA) sets vernacular statement_of_responsibility from 245' do
    result = statement_of_responsibility_vern1['statement_of_responsibility']
    expect(result).to eq(
                        [{"value"=>"杨丹.", "lang"=>"cjk"}]
                      )
  end

  context 'When there is no 245$c value' do
    it '(MTA) sets statement_of_responsibility from 100' do
      rec = make_rec
      rec << MARC::DataField.new('245', '1', '0', ['a', 'Title only'])
      rec << MARC::DataField.new('100', '1', ' ', ['a', 'Name, Author,'], ['d', '1960-'])
      argot = run_traject_on_record('unc', rec)
      result = argot['statement_of_responsibility']
      expect(result).to eq([
                             { "value" => "Name, Author, 1960-" }
                           ])
    end
    it '(MTA) sets statement_of_responsibility from 110 with linked 880' do
      rec = make_rec
      rec << MARC::DataField.new('245', '1', '0', ['a', 'Title only'])
      rec << MARC::DataField.new('110', '2', ' ',
                                 ['6', '880-01'],
                                 ['a', 'Akademii͡a nauk SSSR.'],
                                 ['b', 'Biblioteka.'])
      rec << MARC::DataField.new('880', '2', ' ',
                                 ['6', '110-01/(N'],
                                 ['a', 'Академия наук СССР.'],
                                 ['b', 'Библиотека.'])

      argot = run_traject_on_record('unc', rec)
      result = argot['statement_of_responsibility']
      expect(result).to eq([
                             { "value" => "Akademii͡a nauk SSSR. Biblioteka" },
                             { "value" => "Академия наук СССР. Библиотека", "lang" => "rus" }
                           ])
    end
    it '(MTA) sets statement_of_responsibility from vernacular in 111' do
      rec = make_rec
      rec << MARC::DataField.new('245', '1', '0', ['a', 'Title only'])
      rec << MARC::DataField.new('111', '2', ' ',
                                 ['a', 'Академия наук СССР.'],
                                 ['b', 'Библиотека.'])
      argot = run_traject_on_record('unc', rec)
      result = argot['statement_of_responsibility']
      expect(result).to eq([
                             { "value" => "Академия наук СССР", "lang" => "rus" }
                           ])
    end

  end
end
