# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:statement_of_responsibility) { run_traject_json('duke', 'statement_of_responsibility', 'mrc') }

  it '(MTA) sets statement_of_responsibility' do
    result = statement_of_responsibility['statement_of_responsibility']
    expect(result).to eq(
      [{"value"=>"pod redakt︠s︡īeĭ Grafini Uvarovoĭ."},
       {"value"=>"под редакціей Графини Уваровой.", "lang"=>"rus"}]
    )
  end
end
