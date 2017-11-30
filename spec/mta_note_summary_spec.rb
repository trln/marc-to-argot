# coding: utf-8
require 'spec_helper'
describe MarcToArgot do
  summary01 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'summary01') )
  summary02 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'summary02') )
  summary03 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'summary03') )  
  summary04 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'summary04') )  
  summary05 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'summary05') )
  summary06 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'summary06') )
  summary07 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'summary07') )
  summary08 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'summary08') )
  
  # No additional label provided when i1 = blank
  # Remove -- from the end of subfields
  # Material specified note from $3
  it '(MTA) sets one summary note' do
    result = summary01['note_summary'].size
    expect(result).to(
      eq(1)
    )
  end

  it '(MTA) cleans pre-$c punctuation, adds material specified qualifier' do
    result = summary01['note_summary']
    expect(result).to(
      eq(['(Feature): "Depicts the love of a poet for a princess who travels constantly from this world to the next. A legendary tale in a modern Parisian setting" --Video source book.'])
    )
  end

  it '(MTA) provides pre-$c punctuation' do
    result = summary02['note_summary']
    expect(result).to(
      eq(['"The tracking down of a master criminal in London leads to bitter fighting among the crooks." --Film Index International website.'])
    )
  end

  it '(MTA) sets multiple summary notes' do
    result = summary03['note_summary'][1]
    expect(result).to(
      eq('"Chronicles a year in the life of Dempsey McCall, a deaf biomedical photography resident living in Galveston, Texas" --Provided by publisher.')
    )
  end

  it '(MTA) removes hard-coded summary label' do
    result = summary04['note_summary']
    expect(result).to(
      eq(['A young robin fears to leave the nest, but finds courage and realizes he will never again be afraid to try a new experience.'])
    )
  end

  it '(MTA) provides review label based on i1 = 1' do
    result = summary05['note_summary']
    expect(result).to(
      eq(['Review: Here from Elmore, a review.'])
    )
  end

  it '(MTA) provides scope and content label based on i1 = 2' do
    result = summary06['note_summary']
    expect(result).to(
      eq(['Scope and content: 40 Benchley essays previously published in The Bookman, The Detroit Athletic Club News, The Forum, Life, The New Yorker, and The Yale Review.'])
    )
  end

  it '(MTA) provides abstract label based on i1 = 3' do
    result = summary07['note_summary']
    expect(result).to(
      eq(['Abstract: "This study haz an abstract."--P. iv.'])
    )
  end

  it '(MTA) provides content advice label based on i1 = 4' do
    result = summary08['note_summary'][0]
    expect(result).to(
      eq('Content advice: Bloody violence, strong sexuality, language, and brief drug use.')
    )
  end

end
