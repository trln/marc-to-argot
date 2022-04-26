# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:corpdonor1) { run_traject_json('unc', '791-1') }

  it '(UNC) sets local notes' do
    rec = make_rec
    rec << MARC::DataField.new('590', ' ',  ' ', ['a', 'Test note.'])
    rt = run_traject_on_record('unc', rec)['note_local']
    expect(rt).to eq([{'value' => 'Test note.'}])
  end

  it '(UNC) sets indexed-only local notes from MARC donor fields (790/791)' do
    rec = make_rec
    rec << MARC::DataField.new('791', '2',  ' ', ['a', 'William A. Whitaker Foundation Library Fund.'])
    rec << MARC::DataField.new('790', '0',  ' ', ['a', 'Scaglione, Aldo D.'])
    rt = run_traject_on_record('unc', rec)['note_local']
    expect(rt).to(
      eq([
           {
             'indexed_value' => 'Purchased using funds from the William A. Whitaker Foundation Library Fund.'
           },
           {
             'indexed_value' => 'Donated by Scaglione, Aldo D.'
           }
         ])
    )
  end

end
