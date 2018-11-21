# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::Shared::SubjectGenre

describe MarcToArgot::Macros::Shared::SubjectGenre do
  include Util
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

    it '(MTA) sets subject_topical from 690 a and x' do
      rec = make_rec
      rec << MARC::DataField.new('690', ' ', ' ', ['a', 'foo'], ['x', 'oof'])
      argot = run_traject_on_record('unc', rec)
      result_top = argot['subject_topical']
      result_sh = argot['subject_headings']
      expect(result_top).to eq(['Foo', 'Oof'])
      expect(result_sh).to eq([{ :value => 'Foo -- Oof' }])
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

    it '(MTA) sets subject_topical from 653 with 2nd ind = 4 (instead of subject_chronological)' do
      rec = make_rec
      rec << MARC::DataField.new('653', '0', '4', ['a', 'Sloppy data'])
      rec << MARC::DataField.new('650', '0', '0', ['a', 'Invalid cataloging'], ['y', '21st century'])
      argot = run_traject_on_record('unc', rec)
      result_top = argot['subject_topical']
      result_chron = argot['subject_chronological']
      expect(result_top).to include('Sloppy data')
      expect(result_chron).to eq(['21st century'])
    end

    it '(MTA) sets separate subject headings from repeated 653 subfields' do
      rec = make_rec
      rec << MARC::DataField.new('653', '0', '0',
                                 ['a', 'Cats'],
                                 ['a', 'Goats'])
      argot = run_traject_on_record('unc', rec)
      sh = argot['subject_headings'].map { |e| e[:value] }.sort
      expect(sh).to eq(['Cats', 'Goats'])
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

    context 'when problematic subject headings present' do
      let(:argot1) { rec = make_rec
        rec << MARC::DataField.new('650', ' ', '0',
                                 ['a', 'Illegal aliens'],
                                 ['x', 'Services for'],
                                 ['z', 'United States.'])
        rec << MARC::DataField.new('650', ' ', '0',
                                 ['a', 'Poor'],
                                 ['x', 'Medical care'],
                                 ['z', 'United States.'])
        rec << MARC::DataField.new('650', ' ', '0',
                                 ['a', 'Poor children'],
                                 ['x', 'Dental care'],
                                 ['z', 'United States.'])
        rec << MARC::DataField.new('650', ' ', '0',
                                 ['a', 'Poor.'])
        rec << MARC::DataField.new('650', ' ', '0',
                                 ['a', 'Inoffensive heading'],
                                 ['x', 'Hideous subdivision'],
                                 ['z', 'United States.'])
        rec << MARC::DataField.new('650', ' ', '0',
                                 ['a', 'Illegal Aliens'])
        rec << MARC::DataField.new('690', ' ', ' ',
                                 ['a', 'Illegal Aliens'])
        rec << MARC::DataField.new('690', ' ', ' ',
                                 ['a', 'Netherlands'],
                                 ['x', 'Social Conditions'])
        rec << MARC::DataField.new('690', ' ', ' ',
                                 ['a', 'Illegal Aliens'])
        rec << MARC::DataField.new('690', ' ', ' ',
                                 ['a', 'Netherlands'],
                                 ['x', 'Social Conditions'])
        rec << MARC::DataField.new('690', ' ', ' ',
                                 ['a', 'Illegal Aliens'])
        rec << MARC::DataField.new('690', ' ', ' ',
                                 ['a', 'Netherlands'],
                                 ['x', 'Social Conditions'])
        rec << MARC::DataField.new('690', ' ', ' ',
                                   ['a', 'Illegal Aliens'])
        rec << MARC::DataField.new('690', ' ', ' ',
                                   ['a', 'Netherlands'],
                                   ['x', 'Social Conditions'])
        run_traject_on_record('unc', rec)
                                  }

      it '(MTA) remaps subject heading to better language' do
        sh = argot1['subject_headings'].map { |e| e[:value] }.sort
        expect(sh).to eq([
                           'Inoffensive heading -- Better subdivision -- United States',
                           'Netherlands -- Social Conditions',
                          'Poor children -- Dental care -- United States',
                          'Poor people',
                          'Poor people -- Medical care -- United States',
                          'Undocumented immigrants',
                          'Undocumented immigrants -- Services for -- United States'
                         ])
      end

      it '(MTA) sends problematic heading through as searchable-only' do 
        shr = argot1['subject_headings_remapped'].sort
        expect(shr).to eq(['Illegal Aliens',
                           'Illegal aliens -- Services for -- United States',
                           'Inoffensive heading -- Hideous subdivision -- United States',
                           'Poor',
                           'Poor -- Medical care -- United States'
                          ])
      end

      it '(MTA) remaps subject_topical values to better language' do
        sf = argot1['subject_topical'].sort
        expect(sf).to eq(['Better subdivision',
                          'Dental care',
                          'Inoffensive heading',
                          'Medical care',
                          'Netherlands',
                          'Poor children',
                          'Poor people',
                          'Services for',
                          'Social Conditions',
                          'Undocumented immigrants'
                         ])
      end
    end

    context 'when no subject headings present' do
      let(:argot2) { rec = make_rec
        run_traject_on_record('unc', rec)
      }

      it '(MTA) does not fall over trying to remap nil headings' do
        sh = argot2['subject_headings']
        expect(sh).to be_nil
      end
    end
end
