# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::UNC::Items

describe MarcToArgot::Macros::UNC::Items do
  include Util::TrajectRunTest

  context 'WHEN there is no item data' do
    it '(UNC) does not set item or barcodes field if no item data' do
      rec = make_rec
      argot = run_traject_on_record('unc', rec)
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
                                   ['p', '0501#'],
                                   ['q', '|aML96.4 .B3'])
        rec << MARC::DataField.new('999', '9', '1',
                                   ['p', '090##'],
                                   ['q', '|aML96.4 .B3'])

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

  describe 'setting items[status] -- Each item record to be displayed gets its own detailed status.' do
    context 'WHEN there is one item record attached to bib' do

      rules = {
        '!' => 'On Hold',
        '$' => 'Missing',
        '-' => 'Available',
        'a' => 'Available',
        'b' => 'In Process',
        'c' => 'Missing',
        'd' => 'Missing',
        'e' => 'In Process',
        'f' => 'Missing',
        'g' => 'Ask the MRC',
        'h' => 'Under Review',
        'j' => 'Contact Library for Status',
        'k' => 'In Process',
        'm' => 'Missing',
        'n' => 'Missing',
        'o' => 'In-Library Use Only',
        'p' => 'In Process',
        'r' => 'Being Repaired',
        's' => 'Missing',
        't' => 'In Transit',
        'u' => 'Not Available',
        'v' => 'At the Bindery',
        'w' => 'Withdrawn',
        'z' => 'Missing',        
      }

      rules.each do |code, label|
        context "AND item status = #{code}" do
          it "(UNC) items[status] = #{label}" do
            rec = make_rec
            rec << MARC::DataField.new('999', '9', '1',
                                       ['s', "#{code}"])
            result = run_traject_on_record('unc', rec)['items']
            expect(result[0]).to(
              include("\"status\":\"#{label}\""),
              "with status: #{code}, expected #{label}, got #{result.inspect}"
            )
          end
        end
      end

      context "AND item has a due date value (2066-6-6)" do
        it '(UNC) items[status] = Checked Out' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', '-'],
                                     ['d', '2066-06-06'])
          result = run_traject_on_record('unc', rec)['items']
          expect(result[0]).to( include("\"status\":\"Checked Out\"") )
        end
        it '(UNC) items[due_date] = 20660606' do
          rec = make_rec
          rec << MARC::DataField.new('999', '9', '1',
                                     ['s', '-'],
                                     ['d', '2066-06-06'])
          result = run_traject_on_record('unc', rec)['items']
          expect(result[0]).to( include("\"due_date\":\"20660606\"") )
        end
      end
    end
  end

  describe 'barcode processing' do
    it '(UNC) sets bib-level barcodes field from item data' do
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

    it '(UNC) removes barcode data from items[barcode]' do
      rec = make_rec
      rec << MARC::DataField.new('999', '9', '1',
                                 ['b', '123']
                                )
      argot = run_traject_on_record('unc', rec)
      expect(argot['items'][0]).not_to include("\"barcode\":")
    end
  end

  describe 'setting copy numbers' do
    context 'WHEN item copy number = 1' do
      it '(UNC) does not set items[copy_number]' do
        field = MARC::DataField.new('999', '9', '1',
                                    ['c', '1']
                                   )
        result = assemble_item(field)['copy_no']
        expect(result).to be_nil
      end
    end

    context 'WHEN item copy number > 1' do
      it '(UNC) sets items[copy_number]' do
        field = MARC::DataField.new('999', '9', '1',
                                    ['c', '2']
                                   )
        result = assemble_item(field)['copy_no']
        expect(result).to eq('c. 2')
      end
    end
  end

  describe 'populating item public notes' do
    context 'WHEN there are no public notes in the items' do
      it '(UNC) items[notes] = nil' do
        field = MARC::DataField.new('999', '9', '1',
                                    ['s', '-']
                                   )
        result = assemble_item(field).has_key?('notes')
        expect(result).to eq(false)
      end
    end

    context 'WHEN the item record contains multiple public notes' do
      it '(UNC) extracts all public notes, in order' do
        field = MARC::DataField.new('999', '9', '1',
                                    ['n', 'cat'],
                                    ['n', 'goat']
                                   )
        result = assemble_item(field)['notes']
        expect(result).to eq(['cat', 'goat'])
      end
    end
  end

end
