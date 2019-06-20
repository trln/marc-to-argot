# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::UNC::Items

describe MarcToArgot::Macros::UNC::Items do
  include Util::TrajectRunTest

  context 'WHEN there is no item data' do
  it '(UNC) does not set item or barcodes field if no item data' do
    rec = make_rec
    argot = run_traject_on_record('unc', rec)
    expect(argot['items']).to be_nil
    expect(argot['barcodes']).to be_nil
  end
  end

  describe 'setting call number values in UNC items' do
    context 'WHEN call_no in item 099 field' do
      it '(UNC) cn_scheme = ALPHANUM' do
        rec = make_rec
        rec << MARC::DataField.new('999', '9', '1',
                                   ['i', 'i10202491'],
                                   ['l', 'lljd'],
                                   ['s', '-'],
                                   ['t', '22'],
                                   ['c', '1'],
                                   ['o', '0'],
                                   ['b', '00047641015'],
                                   ['p', '099#9'],
                                   ['q', '|aJ|aVillar'])
        result = run_traject_on_record('unc', rec)['items'][0]
        expect(result).to(
          include("\"cn_scheme\":\"ALPHANUM\"")
        )
        expect(result).to(
          include("\"call_no\":\"J Villar\"")
        )
      end
    end

    context 'WHEN call_no in item 086 field' do
      context 'AND ind1 = 0' do
        it '(UNC) cn_scheme = SUDOC' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['i', 'i4808951'],
                                     ['l', 'dcpf'],
                                     ['s', '-'],
                                     ['t', '20'],
                                     ['c', '1'],
                                     ['o', '0'],
                                     ['b', 'HAYZ-5955-00001'],
                                     ['p', '0860#'],
                                     ['q', '|aHE 1.1008:H 75/5'])

          result = run_traject_on_record('unc', rec)['items'][0]
          expect(result).to(
            include("\"cn_scheme\":\"SUDOC\"")
          )
          expect(result).to(
            include("\"call_no\":\"HE 1.1008:H 75/5\"")
          )
        end
      end
    end

    context 'WHEN call_no in item 050 or 090 field' do
      it '(UNC) cn_scheme = LC' do
        rec = make_rec
        rec << MARC::DataField.new('999', '9', '1',
                                   ['i', 'i1688265'],
                                   ['l', 'mmdb'],
                                   ['s', '-'],
                                   ['t', '44'],
                                   ['c', '1'],
                                   ['o', '1'],
                                   ['b', '00009823818'],
                                   ['p', '0501#'],
                                   ['q', '|aML96.4 .B3'],
                                   ['v', 'Bd.2'])
        rec << MARC::DataField.new('999', '9', '1',
                                   ['i', 'i1688266'],
                                   ['l', 'mmdb'],
                                   ['s', '-'],
                                   ['t', '1'],
                                   ['c', '2'],
                                   ['o', '5'],
                                   ['b', '00012707519'],
                                   ['p', '090##'],
                                   ['q', '|aML96.4 .B3'],
                                   ['v', 'Bd.2'])

        result = run_traject_on_record('unc', rec)['items']
        expect(result[0]).to(
          include("\"cn_scheme\":\"LC\"")
        )
        expect(result[1]).to(
          include("\"cn_scheme\":\"LC\"")
        )
        expect(result[0]).to(
          include("\"call_no\":\"ML96.4 .B3\"")
        )
        expect(result[1]).to(
          include("\"call_no\":\"ML96.4 .B3\"")
        )
      end
    end

    context 'WHEN call_no in item 082 or 092 field' do
      it '(UNC) cn_scheme = DDC' do
        rec = make_rec
        rec << MARC::DataField.new('999', '9', '1',
                                   ['i', 'i1688265'],
                                   ['l', 'mmdb'],
                                   ['s', '-'],
                                   ['t', '44'],
                                   ['c', '1'],
                                   ['o', '1'],
                                   ['b', '00009823818'],
                                   ['p', '082##'],
                                   ['q', '|a781.9733 M939a2'],
                                   ['v', 'Bd.2'])
        rec << MARC::DataField.new('999', '9', '1',
                                   ['i', 'i1688266'],
                                   ['l', 'mmdb'],
                                   ['s', '-'],
                                   ['t', '1'],
                                   ['c', '2'],
                                   ['o', '5'],
                                   ['b', '00012707519'],
                                   ['p', '092##'],
                                   ['q', '|a781.9733 M939a2'],
                                   ['v', 'Bd.2'])

        result = run_traject_on_record('unc', rec)['items']
        expect(result[0]).to(
          include("\"cn_scheme\":\"DDC\"")
        )
        expect(result[1]).to(
          include("\"cn_scheme\":\"DDC\"")
        )
        expect(result[0]).to(
          include("\"call_no\":\"781.9733 M939a2\"")
        )
        expect(result[1]).to(
          include("\"call_no\":\"781.9733 M939a2\"")
        )
      end
    end
  end

  describe 'setting volume values in UNC items' do
    context 'WHEN item volume field is present' do
      it '(UNC) sets volume value' do
        rec = make_rec
        rec << MARC::DataField.new('999', '9', '1',
                                   ['i', 'i1688265'],
                                   ['l', 'mmdb'],
                                   ['s', '-'],
                                   ['t', '44'],
                                   ['c', '1'],
                                   ['o', '1'],
                                   ['b', '00009823818'],
                                   ['p', '0501#'],
                                   ['q', '|aML96.4 .B3'],
                                   ['v', 'Bd.2'])

        result = run_traject_on_record('unc', rec)['items']
        expect(result[0]).to(
          include("\"vol\":\"Bd.2\"")
        )
      end
    end
  end

  describe 'setting bib-level availability values from UNC items -- ie the one binary (Available/Not Available) value for the bib, which may have multiple items with varying statuses attached' do
    context 'WHEN there is one item record attached to bib' do
      context 'AND item status = ! (On Hold)' do
        it '(UNC) available = Not Available' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', '!'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( be_nil)
        end
      end
      context 'AND item status = $, c, d, f, m, n, s, or z (Missing)' do
        it '(UNC) available = Not Available' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', '$'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( be_nil)

                  rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', 'c'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( be_nil)

          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', 'd'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( be_nil)

          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', 'f'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( be_nil)

          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', 'm'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( be_nil)

                  rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', 'n'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( be_nil)

          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', 's'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( be_nil)

          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', 'z'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( be_nil)
        end
      end
      context 'AND item status = - or a (Available)' do
        it '(UNC) available = Available' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', '-'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( eq("Available"))

          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', 'a'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( eq("Available"))
        end
      end
      %w{b e k p}.each do |code|
      context "AND item status = #{code} (In Process)" do
          it '(UNC) available = Not Available' do
            rec = make_rec
            rec << MARC::DataField.new('999', '9', '1',
                                       ['s', code])
            result = run_traject_on_record('unc', rec)['available']
            expect(result).to be_nil, "with status:#{code}, expected nil, got #{result.inspect}"
          end
        end
      end
      context 'AND item status = f (Never Received)' do
        it '(UNC) available = Available' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', 'o'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( eq("Available"))
        end
      end
      context 'AND item status = o (In-Library Use Only)' do
        it '(UNC) available = Available' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', 'o'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( eq("Available"))
        end
      end
      context 'AND item status = o (In-Library Use Only)' do
        it '(UNC) available = Available' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', 'o'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( eq("Available"))
        end
      end
      context 'AND item status = o (In-Library Use Only)' do
        it '(UNC) available = Available' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', 'o'])
          result = run_traject_on_record('unc', rec)['available']
          expect(result).to( eq("Available"))
        end
      end
    end

    context 'bib has multiple items attached' do
      context 'AND multiple items have statuses that map to Not Available' do
        context 'BUT at least one item has a status that maps to Available' do
          it '(UNC) sets bib level available to Available' do
            rec = make_rec
            rec << MARC::DataField.new('999', '9', '1',
                                       ['s', '-'])
            rec << MARC::DataField.new('999', '9', '1',
                                       ['s', '-'],
                                       ['d', '2066-6-6'])
            rec << MARC::DataField.new('999', '9', '1',
                                       ['s', 'm'])
            rec << MARC::DataField.new('999', '9', '1',
                                       ['s', 'f'])
            argot = run_traject_on_record('unc', rec)
            expect(argot['available']).to eq('Available')
          end
        end

        context 'AND no item statuses map to Available' do
          it '(UNC) does not set bib-level available field' do
            rec = make_rec
            rec << MARC::DataField.new('999', '9', '1',
                                       ['s', 'w']
                                      )
            rec << MARC::DataField.new('999', '9', '1',
                                       ['s', '-'],
                                       ['d', '2019-6-6']
                                      )
            argot = run_traject_on_record('unc', rec)
            expect(argot['available']).to be_nil
          end
        end
      end
    end
  end

  describe 'setting bib-level location_hierarchy values from UNC items' do
    context 'bib record has item for valid print location' do
      it '(UNC) sets bib level location_hierarchy for print location' do
        rec = make_rec
        rec << MARC::DataField.new('999', '9', '1',
                                   ['l', 'ggda']
                                  )
        argot = run_traject_on_record('unc', rec)
        expect(argot['location_hierarchy']).to eq(['unc', 'unc:uncrarn', 'unc:uncwil', 'unc:uncwil:uncwilrbc'])
      end

      context 'AND has unsuppressed e-resource item' do
        it '(UNC) sets bib level location_hierarchy for print location only' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['i', 'i1688265'],
                                     ['l', 'dcpf'],
                                     ['v', 'Bd.2'])
          rec << MARC::DataField.new('999', '9', '1',
                                     ['i', 'i1688265'],
                                     ['l', 'erra'],
                                     ['v', 'Bd.2'])

          result = run_traject_on_record('unc', rec)['location_hierarchy']
          expect(result).to(
            eq(['unc', 'unc:uncdavy', 'unc:uncdavy:uncdavdoc'])
          )
        end
      end
    end
  end

  describe 'setting bib-level location_hierarchy values from UNC items' do
  it '(UNC) sets bib-level barcodes field' do
    rec = make_rec
    rec << MARC::DataField.new('999', '9', '1',
                               ['b', '123']
                              )
    rec << MARC::DataField.new('999', '9', '1',
                               ['b', '456']
                              )
    argot = run_traject_on_record('unc', rec)
    expect(argot['barcodes']).to eq(['123', '456'])
  end

  it '(UNC) removes barcode data from items field' do
    rec = make_rec
    rec << MARC::DataField.new('999', '9', '1',
                               ['b', '123']
                              )
    argot = run_traject_on_record('unc', rec)
    expect(argot['items'][0]).not_to include("\"barcode\":")
  end
  end

  describe 'assemble_item' do
    it '(UNC) does not set copy number 1' do
      field = MARC::DataField.new('999', '9', '1',
                                  ['c', '1']
                                 )
      result = assemble_item(field)['copy_no']
      expect(result).to be_nil
    end

    it '(UNC) set copy number when > 1' do
      field = MARC::DataField.new('999', '9', '1',
                                  ['c', '2']
                                 )
      result = assemble_item(field)['copy_no']
      expect(result).to eq('c. 2')
    end

    it '(UNC) sets status to Checked out when due date present' do
      field = MARC::DataField.new('999', '9', '1',
                                  ['s', '-'],
                                  ['d', '2019-04-17 04:00:00-04']
                                 )
      result = assemble_item(field)['status']
      expect(result).to eq('Checked out')
    end

    it '(UNC) does not set due date when item is available' do
      field = MARC::DataField.new('999', '9', '1',
                                  ['s', '-']
                                 )
      result = assemble_item(field).has_key?('due_date')
      expect(result).to eq(false)
    end

    it '(UNC) does not set notes subelement when there are no public notes' do
      field = MARC::DataField.new('999', '9', '1',
                                  ['s', '-']
                                 )
      result = assemble_item(field).has_key?('notes')
      expect(result).to eq(false)
    end

    it '(UNC) compiles multiple public notes' do
      field = MARC::DataField.new('999', '9', '1',
                                  ['n', 'cat'],
                                  ['n', 'goat']
                                 )
      result = assemble_item(field)['notes']
      expect(result).to eq(['cat', 'goat'])
    end
  end
  




end
