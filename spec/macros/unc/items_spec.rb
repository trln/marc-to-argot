# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::UNC::Items

describe MarcToArgot::Macros::UNC::Items do
  include Util::TrajectRunTest

      # rec << MARC::DataField.new('999', '9', '1',
      #                          ['i', 'i1147335'],
      #                          ['l', 'ddda'],
      #                          ['s', '-'],
      #                          ['t', '0'],
      #                          ['c', '1'],
      #                          ['o', '18'],
      #                          ['b', '123'],
      #                          ['p', '090##'],
      #                          ['q', '|aPB1423.C8 G7']
      #                         )
  let(:b7667969result) { run_traject_json('unc', 'b7667969')['items'][0] }

  it '(UNC) sets item cn_scheme to ALPHANUM when call_no is in 099 (single item record)' do
    expect(b7667969result).to(
      include("\"cn_scheme\":\"ALPHANUM\"")
    )
  end

  it '(UNC) sets item call_no (alphanumeric) from multiple subfield a values (single item record)' do
    expect(b7667969result).to(
      include("\"call_no\":\"J Villar\"")
    )
  end

    # test on b3388632
  let(:b3388632result) { run_traject_json('unc', 'b3388632')['items'][0] }

  it '(UNC) sets item cn_scheme to SUDOC when call_no is in 086 w/i1 = 0 (single item record)' do
    expect(b3388632result).to(
      include('"cn_scheme":"SUDOC"')
    )
  end

  # test on b1319986
  let(:b1319986argot) { run_traject('unc', 'b1319986') }
  let(:b1319986result0) { JSON.parse(b1319986argot)['items'][0] }
  let(:b1319986result1) { JSON.parse(b1319986argot)['items'][1] }

  it '(UNC) sets item cn_scheme to LC when call_no is in 050' do
    expect(b1319986result0).to(
      include("\"cn_scheme\":\"LC\"")
    )
  end

  it '(UNC) sets item vol' do
    expect(b1319986result0).to(
      include("\"vol\":\"Bd.2\"")
    )
  end

  #test on b4069204
  let(:b4069204argot) { run_traject('unc', 'b4069204') }
  let(:b4069204result0) { JSON.parse(b4069204argot)['items'][0] }

  it '(UNC) sets item cn_scheme to DDC when call_no is in 092' do
    expect(b4069204result0).to(
      include("\"cn_scheme\":\"DDC\"")
    )
  end

  #test on b2975416
  let(:b2975416argot) { run_traject('unc', 'b2975416') }
  let(:b2975416result) { JSON.parse(b2975416argot)['items'] }

  it '(UNC) sets available to Available if status is In-Library Use Only' do
    expect(JSON.parse(b2975416argot)['available']).to(
      eq("Available")
    )
  end

  let(:eresloc) { run_traject_json('unc', 'location_eres') }

  it '(UNC) sets location_hierarchy for record with unsuppressed e-items' do
    expect(eresloc['location_hierarchy']).to(
      eq(['unc', 'unc:uncdavy', 'unc:uncdavy:uncdavdoc'])
    )
  end

  it '(UNC) sets barcodes field' do
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

  it '(UNC) removes barcode from item json' do
    rec = make_rec
    rec << MARC::DataField.new('999', '9', '1',
                               ['b', '123']
                              )
    argot = run_traject_on_record('unc', rec)
    expect(argot['items'][0]).not_to include("\"barcode\":")
  end

  it '(UNC) sets available field value to Available if at least one item is available' do
    rec = make_rec
    rec << MARC::DataField.new('999', '9', '1',
                               ['s', '-']
                              )
    rec << MARC::DataField.new('999', '9', '1',
                               ['s', '-'],
                               ['d', '2019-6-6']
                              )
    argot = run_traject_on_record('unc', rec)
    expect(argot['available']).to eq('Available')
  end
  
  it '(UNC) does not set available field if no items are available' do
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

  it '(UNC) sets location facet values' do
    rec = make_rec
    rec << MARC::DataField.new('999', '9', '1',
                               ['l', 'ggda']
                              )
    argot = run_traject_on_record('unc', rec)
    expect(argot['location_hierarchy']).to eq(['unc', 'unc:uncrarn', 'unc:uncwil', 'unc:uncwil:uncwilrbc'])
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
