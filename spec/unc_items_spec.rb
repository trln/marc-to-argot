require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:b1082803argot) { run_traject_json('unc', 'b1082803') }

  it '(UNC) sets item id (single item record)' do
    expect(b1082803argot['items'][0]).to(
      include("\"id\":\"i1147335\"")
    )
  end

  it '(UNC) sets item loc_b and loc_n (single item record)' do
    expect(b1082803argot['items'][0]).to(
      include("\"loc_b\":\"ddda\",\"loc_n\":\"ddda\"")
    )
  end

  it '(UNC) sets location_hierarchy from loc_b (single loc)' do
    expect(b1082803argot['location_hierarchy']).to(
      eq(['unc', 'unc:uncdavy'])
    )
  end

  it '(UNC) sets item status to Available (single item record)' do
    expect(b1082803argot['items'][0]).to(
      include("\"status\":\"Available\"")
    )
  end

  it '(UNC) does NOT set item due date when status is Available (single item record)' do
    expect(b1082803argot['items'][0]).not_to(
      include("\"due_date\":")
    )
  end

  it '(UNC) does NOT set item copy_no when it equals 1 (single item record)' do
    expect(b1082803argot['items'][0]).not_to(
      include("\"copy_no\":")
    )
  end

  it '(UNC) sets item cn_scheme to LC when call_no is in 090 (single item record)' do
    expect(b1082803argot['items'][0]).to(
      include("\"cn_scheme\":\"LC\"")
    )
  end

  it '(UNC) sets item call_no for normal LC (single item record)' do
    expect(b1082803argot['items'][0]).to(
      include("\"call_no\":\"PB1423.C8 G7\"")
    )
  end

  # test on b3388632
  let(:b3388632result) { run_traject_json('unc', 'b3388632')['items'][0] }

  it '(UNC) sets item cn_scheme to SUDOC when call_no is in 086 w/i1 = 0 (single item record)' do
    expect(b3388632result).to(
      include('"cn_scheme":"SUDOC"')
    )
  end

  # test on b7667969
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

  it '(UNC) sets copy_no when greater than 1' do
    expect(b1319986result1).to(
      include("\"copy_no\":\"2\"")
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

  it '(UNC) sets due date' do
    expect(b2975416result[1]).to(
      include("\"due_date\":\"2018-01-30\"")
    )
  end

  it '(UNC) sets status to Checked out' do
    expect(b2975416result[1]).to(
      include("\"status\":\"Checked out\"")
    )
  end

  it '(UNC) sets multiple item notes in correct order' do
    expect(b2975416result[1]).to(
      include("\"notes\":[\"zzTest note\",\"aaTest note\"]")
    )
  end

  it '(UNC) does NOT set item notes when there are none' do
    expect(b2975416result[0]).not_to(
      include("\"notes\":[]")
    )
  end

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

  let(:wilson_loc_argot) { run_traject_json('unc', 'wilson_loc') }

  it '(UNC) sets multi location_hierarchy from one loc_b (single loc)' do
    expect(wilson_loc_argot['location_hierarchy']).to(
      eq(['unc', 'unc:uncrarn', 'unc:uncwil', 'unc:uncwil:uncwilrbc'])
    )
  end

  let(:multi_loc_argot) { run_traject_json('unc', 'multi_loc') }

  it '(UNC) sets multi location_hierarchy from multi loc_bs in multiple item records' do
    expect(multi_loc_argot['location_hierarchy'].sort).to(
      eq(['hsl', 'hsl:hsluncy', 'unc', 'unc:unchsl', 'unc:uncrarn', 'unc:uncwil', 'unc:uncwil:uncwilrbc'])
    )
  end

  it '(UNC) sets single barcodes value' do
    expect(b1082803argot['barcodes']).to(
      eq(['00007525537'])
    )
  end

  let(:b1246383argot) { run_traject_json('unc', 'b1246383') }
  it '(UNC) sets multiple barcodes values' do
    expect(b1246383argot['barcodes']).to(
      eq(['00036388532', '00036429481', '00036429490'])
    )
  end
end
