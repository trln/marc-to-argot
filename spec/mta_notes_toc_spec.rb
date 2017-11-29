# coding: utf-8
require 'spec_helper'
describe MarcToArgot do
  toc01 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'toc01') )
  toc02 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'toc02') )
  toc03 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'toc03') )  

  # only subfields agrt will be kept/displayed.
  # subfield u allows a URL to be put in the field. Do we want that? 
  it '(MTA) sets single basic TOC note' do
    result = toc01['note_toc']
    expect(result).to(
      eq(['Basic 505 with i1=0.'])
    )
  end

  # Provides 'Incomplete contents:' based on 1st indicator = 1
  it '(MTA) sets single enhanced incomplete TOC note' do
    result = toc02['note_toc']
    expect(result).to(
      eq(['Incomplete contents: Non-indexed contextual info: Chapter 1 title / Chapter 1 author -- Chapter 2 title / Chapter 2 author.'])
    )
  end

  # Provides 'Partial contents:' based on 1st indicator = 2
  # Strips trailing spaces from subfields
  # Keeps multiple 505s in order
  it '(MTA) sets multiple enhanced partial TOC notes' do
    result = toc03['note_toc']
    expect(result).to(
      eq(['Partial contents: Non-indexed contextual info: Chapter 1 title / Chapter 1 author -- Chapter 2 title / Chapter 2 author --', 'ARound 2: Chapter 3 title / Chapter 3 author -- Chapter 4 title / Chapter 4 author.'])
    )
  end
end
