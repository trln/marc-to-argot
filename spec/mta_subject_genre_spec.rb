# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:subject1) { run_traject_json('unc', 'subject1', 'mrc') }
  let(:subject2) { run_traject_json('unc', 'subject2', 'mrc') }
  let(:subject3) { run_traject_json('unc', 'subject3', 'mrc') }
  let(:subject4) { run_traject_json('unc', 'subject4', 'mrc') }
  let(:primary_source1) { run_traject_json('unc', 'primary_source1', 'mrc') }
  let(:primary_source2) { run_traject_json('unc', 'primary_source2', 'mrc') }
  let(:genre1) { run_traject_json('unc', 'genre1', 'mrc') }
  let(:genre2) { run_traject_json('unc', 'genre2', 'mrc') }
  let(:genre3) { run_traject_json('unc', 'genre3', 'mrc') }
  let(:genre4) { run_traject_json('unc', 'genre4', 'mrc') }
  let(:genre5) { run_traject_json('unc', 'genre5', 'mrc') }
  let(:genre6) { run_traject_json('unc', 'genre6', 'mrc') }
  let(:genre7) { run_traject_json('unc', 'genre7', 'mrc') }
  let(:genre8) { run_traject_json('unc', 'genre8', 'mrc') }
  let(:vern650v) { run_traject_json('unc', 'vern650v', 'mrc') }
  let(:vern655ara) { run_traject_json('unc', 'vern655ara', 'mrc') }
  let(:duke_genre_edge_case) { run_traject_json('duke', 'subject_genre_655_edge_case', 'xml') }

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

  it '(MTA) subdivides personal name headings correctly' do
    result = subject3['subject_headings']
    expect(result).to include(
                        {"value" => "Shakespeare, William, 1564-1616 -- Musical settings"}
                      )
  end

  it '(MTA) subdivides corporate name headings correctly' do
    result = subject3['subject_headings']
    expect(result).to include(
                        {"value" => "North Carolina. Provincial Congress (4th : 1776 : Halifax, N.C.) -- Drama"}
                      )
  end

  it '(MTA) subdivides meeting name headings correctly' do
    result = subject3['subject_headings']
    expect(result).to include(
                        {"value" => "Vatican Council (2nd : 1962-1965 : Basilica di San Pietro in Vaticano) -- Drama"}
                      )
  end

    it '(MTA) subdivides geographic name headings correctly' do
    result = subject4['subject_headings']
    expect(result).to include(
                        {"value" => "Cary (N.C.) -- Description and travel"}
                      )
  end

  it '(MTA) subdivides uniform title headings correctly' do
    result = subject3['subject_headings']
    expect(result).to include(
                        {"value" => "Bible. Gospels -- Commentaries"}
                      )
  end

  it '(MTA) adds personal name to subject_topical correctly' do
    result = subject3['subject_topical']
    expect(result).to include(
                        "Shakespeare, William, 1564-1616"
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

  it '(MTA) keeps a and g together in subject_geographic from 651' do
    result = genre3['subject_geographic']
    expect(result).to include(
                          "Broadway -- New York, NY"
                      )
  end

  it '(MTA) separates 662 subfield values in subject_geographic' do
    result = genre3['subject_geographic']
    expect(result).to include(
                        "United States",
                        "Vermont",
                        "Green Mountain National Forest"
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

  it '(MTA) adds Reference genre facet value when that facet includes Dictionaries' do
    result = genre8['subject_genre']
    expect(result).to include(
                        'Reference'
                      )
  end


  it '(MTA) adds genre facet value from 006 LitForm byte independent of LDR values' do
    result = genre1['subject_genre']
    expect(result).to include(
                        'Nonfiction'
                      )
  end

  it '(MTA) sets genre facet to Biography from 008/34' do
    result = genre3['subject_genre']
    expect(result).to include(
                        'Biography'
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

    it '(MTA) sets subject headings values from 653 with 2nd ind = blank' do
      result = genre5['subject_headings']
      expect(result).to include(
                          {'value' => 'Mattel'},
                        )
    end

    it '(MTA) sets separate genre headings values from 382 subfields' do
      result = genre6['genre_headings']
      expect(result).to include(
                          {'value' => 'Oboe'},
                          {'value' => 'Orchestra'}
                        )
    end

    it '(MTA) sets separate subject_genre values from 382 subfields' do
      result = genre6['subject_genre']
      expect(result).to include(
                          'Oboe',
                          'Orchestra'
                        )
    end

    it '(MTA) sets genre headings values from 384' do
      result = genre7['genre_headings']
      expect(result).to include(
                          {'value' => 'C♯ minor'}
                        )
    end

    it '(MTA) sets genre facet values from 384' do
      result = genre7['subject_genre']
      expect(result).to include(
                          'C♯ minor'
                        )
    end

    it '(MTA) sets genre headings values from 567$b' do
      result = genre7['genre_headings']
      expect(result).to include(
                          {'value' => 'Narrative inquiry (Research method)'}
                        )
    end

    it '(MTA) sets the genre_headings field values without errors or empty values' do
      result = duke_genre_edge_case['genre_headings']
      expect(result).to eq([{"value" => "دمنتري فلمس", "lang"=>"ara"},
                            {"value" => "ننفتن فلمس", "lang"=>"ara"},
                            {"value" => "فتر فلمس", "lang"=>"ara"}])
    end

    it '(MTA) sets the subject genre field values without errors or empty values' do
      result = duke_genre_edge_case['subject_genre']
      expect(result).to eq(["دمنتري فلمس",
                            "ننفتن فلمس",
                            "فتر فلمس"])
    end

    it '(MTA) sets subject_headings from 880 field' do
      result = vern650v['subject_headings']
      expect(result).to include(
                          { "value" => "按摩疗法(中医) -- 教材",
                            "lang" => "cjk"}
                        )
    end

    it '(MTA) sets subject_topical from 880 field' do
      result = vern650v['subject_topical']
      expect(result).to include(
                          "按摩疗法(中医)",
                        )
    end

    it '(MTA) sets subject_genre from 880 field' do
      result = vern650v['subject_genre']
      expect(result).to include(
                          "教材"
                        )
    end

    it '(MTA) sets genre_headings from 880 field' do
      result = vern655ara['genre_headings']
      expect(result).to include(
                          { 'value' => 'أعمال مبكرة إلى 1800',
                            'lang' => 'ara' }
                        )
    end
end
