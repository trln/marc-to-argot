# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::Shared::WorkEntry do
  include Util::TrajectRunTest
  let(:non_filing_chars_consume_title) { run_traject_json('unc', 'non_filing_chars_consume_title', 'xml')}
  let(:work_entry_no_main_entry) { run_traject_json('unc', 'work_entry_no_main_entry', 'xml') }

  it '(MTA) handles too many non-filing characters' do
    result = non_filing_chars_consume_title['this_work']
    expect(result).to eq(
      [{"type"=>"this",
        "author"=>"Strugat͡skiĭ, Arkadiĭ, 1925-1991.",
        "title"=>["Les"]}]
    )
  end

  it '(MTA) handles work_entry with no main entry' do
    result = work_entry_no_main_entry['this_work']
    expect(result).to eq([{"type"=>"this",
                           "title"=>["Biological Wastewater Treatment"]}])
  end
end
