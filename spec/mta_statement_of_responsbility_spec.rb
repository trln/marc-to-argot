# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
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
end
