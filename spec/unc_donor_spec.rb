# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  
  it '(UNC) sets donor from 791 field with indicators 2b' do
    rec = make_rec
    rec << MARC::DataField.new('791', '2',  ' ', ['a', 'William A. Whitaker Foundation Library Fund.'])
    rec << MARC::DataField.new('790', '0',  ' ', ['a', 'Scaglione, Aldo D.'])
    rt = run_traject_on_record('unc', rec)['donor']
    expect(rt).to(
      eq([
           {
             'value' => 'Purchased using funds from the William A. Whitaker Foundation Library Fund.'
           },
           {
             'value' => 'Donated by Scaglione, Aldo D.'
           }
         ])
    )
  end

  it '(UNC) sets donor from 790 with \'From the library of...\'' do
    rec = make_rec
    rec << MARC::DataField.new('790', '0',  ' ',
                               ['a', 'From the library of Gertrude Weil 1879-1971.'])
    rt = run_traject_on_record('unc', rec)['donor']
    expect(rt).to(
      eq([
           {
             'value' => 'From the library of Gertrude Weil 1879-1971.'
           }
         ])
    )
  end
  
  it '(UNC) sets donor without including relators' do
    rec = make_rec
    rec << MARC::DataField.new('790', '0',  ' ',
                               ['a', 'Engstrom, Alfred G.,'],
                               ['d', '1907-1990,'],
                               ['e', 'former owner (RBC)'])
    rt = run_traject_on_record('unc', rec)['donor']
    expect(rt).to(
      eq([
           {
             'value' => 'Donated by Engstrom, Alfred G., 1907-1990'
           }
         ])
    )
  end

    xit '(UNC) sets CJK donor without including relators' do
    rec = make_rec
    rec << MARC::DataField.new('790', '0',  ' ',
                               ['a', '陳嘉猷,'],
                               ['e', 'former owner'])
    rt = run_traject_on_record('unc', rec)['donor']
    expect(rt).to(
      eq([
           {
             'value' => 'Donated by 陳嘉猷',
             'lang' => 'cjk'
           }
         ])
    )
  end

end
