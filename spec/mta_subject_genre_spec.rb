# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:subject1) { run_traject_json('unc', 'subject1', 'mrc') }
  let(:subject2) { run_traject_json('unc', 'subject2', 'mrc') }
  let(:primary_source1) { run_traject_json('unc', 'primary_source1', 'mrc') }
  let(:primary_source2) { run_traject_json('unc', 'primary_source2', 'mrc') }
  let(:genre1) { run_traject_json('unc', 'genre1', 'mrc') }
  let(:genre2) { run_traject_json('unc', 'genre2', 'mrc') }
  let(:genre3) { run_traject_json('unc', 'genre3', 'mrc') }
  let(:genre4) { run_traject_json('unc', 'genre4', 'mrc') }
  
  it '(MTA) sets subject_headings from any source' do
    result = subject1['subject_headings']
    expect(result).to eq(
                        [
                          { "value" => "Asperger, Hans" },
                          { "value" => "Asperger's syndrome in children -- Patients -- Austria -- Vienna -- History" },
                          { "value" => "Asperger's syndrome in children -- Austria -- Vienna -- Diagnosis -- 20th century" },
                          { "value" => "Asperger's syndrome in children -- Austria -- Vienna -- History -- 20th century" },
                          { "value" => "MEDICAL / Pediatrics" },
                          { "value" => "Asperger Syndrome -- History" }
                        ]
                      )
  end

  it '(MTA) sets and deduplicates genre_headings' do
    result = subject1['genre_headings']
    expect(result).to eq(
                        [
                          { "value" => "Nonfiction" }
                        ]
                      )
  end

  it '(MTA) sets and deduplicates subject_genre' do
    result = subject1['subject_genre']
    expect(result).to eq(
                        [
                          "Nonfiction"
                        ]
                      )
  end  

  it '(MTA) sets and deduplicates subject_geographic' do
    result = subject1['subject_geographic']
    expect(result).to eq(
                        [
                          "Austria",
                          "Vienna"
                        ]
                      )
  end
  
  it '(MTA) sets and deduplicates subject_topical' do
    result = subject1['subject_topical']
    expect(result).to eq(
                        [
                          "Asperger, Hans",
                          "Asperger's syndrome in children",
                          "Patients",
                          "History",
                          "Diagnosis",
                          "MEDICAL / Pediatrics",
                          "Asperger Syndrome"
                        ]
                      )
  end
  
  it '(MTA) sets and deduplicates subject_chronological' do
    result = subject1['subject_chronological']
    expect(result).to eq(
                        [
                          "20th century"
                        ]
                      )
  end

  it '(MTA) removes RB vocab terms from genre headings' do
    result = subject2['genre_headings']
    expect(result).to eq(
                        [
                          { "value" => "Marginalia -- Ithaca -- 20th century" },
                          { "value" => "Letterpress types -- Colorado -- 21st century" },
                          { "value" => "Publishers' cloth bindings -- Mexico -- 20th century" },
                          { "value" => "Poems -- England -- London -- 18th century" },
                          { "value" => "Marbled papers" },
                          { "value" => "Printers' devices -- Scotland -- Edinburgh -- 19th century" },
                          { "value" => "Review copies -- New York (State) -- 20th century" },
                          { "value" => "Marbled papers (Paper)" }
                        ]
                      )
  end

  it '(MTA) removes RB vocab terms from genre facet values' do
    result = subject2['subject_genre']
    expect(result).to eq(
                        [
                          "Marginalia",
                          "Letterpress types",
                          "Publishers' cloth bindings",
                          "Poems",
                          "Marbled papers",
                          "Printers' devices",
                          "Review copies",
                          "Marbled papers (Paper)",
                          "Nonfiction"
                        ]
                      )
  end  

  it '(MTA) adds Primary sources genre facet value when that facet includes Diaries' do
    result = primary_source1['subject_genre']
    expect(result).to include(
                        'Primary sources'
                      )
  end  

  it '(MTA) adds Primary sources genre facet value when that facet includes Notebooks, sketchbooks, etc.' do
    result = primary_source2['subject_genre']
    expect(result).to include(
                        'Primary sources'
                      )
  end  

  it '(MTA) adds genre facet value from 006 alone' do
    result = genre1['subject_genre']
    expect(result).to include(
                        'Nonfiction'
                      )
  end  

  it '(MTA) keeps 655ax together in genre facet' do
    result = genre2['subject_genre']
    expect(result).to include(
                        'American Literature -- Adaptations'
                      )
  end  
  
  it '(MTA) splits 655av in genre facet' do
    result = genre3['subject_genre']
    expect(result).to include(
                        'Spy stories',
                        'Comic books, strips, etc'
                      )
  end  
  
  it '(MTA) sets genre facet values from 656 k and v' do
    result = genre3['subject_genre']
    expect(result).to include(
                        'School district case files',
                        'Indexes'
                      )
  end

    it '(MTA) sets subject headings values from 656' do
    result = genre3['subject_headings']
    expect(result).to include(
                        {'value' => 'Migrant laborers -- School district case files -- Indexes'},
                      )
    end

    it '(MTA) sets genre facet from 653 with 2nd ind = 6' do
      result = genre4['subject_genre']
      expect(result).to include(
                          'Graphic novels'
                        )
    end

    it '(MTA) sets genre headings values from 653 with 2nd ind = 6' do
    result = genre4['genre_headings']
    expect(result).to include(
                        {'value' => 'Graphic novels'},
                      )
    end
end

