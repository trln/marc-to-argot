require 'spec_helper'
require 'util'
require 'marc_to_argot'
require 'json'

describe MarcToArgot do
  class TrajectRunTest
    def self.run_traject(collection, file, extension = 'xml')
      indexer = Util::TrajectLoader.load(collection, extension)
      test_file = Util.find_marc(collection, file, extension)
      Util.capture_stdout do |_|
        indexer.process(File.open(test_file))
      end
    end
  end

  it 'has a version number' do
    expect(MarcToArgot::VERSION).not_to be nil
  end

  it 'loads base spec successfully' do
    spec = MarcToArgot::SpecGenerator.new('argot')
    result = spec.generate_spec
    expect(result).to be_kind_of(Hash)
    expect(result).not_to be_empty
    expect(result['id']).to eq('001')
  end

  it 'loads NCSU spec without a problem' do
    spec = MarcToArgot::SpecGenerator.new('ncsu')
    result = spec.generate_spec
    expect(result['id']).to eq('918a')
  end

  it 'generates base results for NCSU' do
    result = TrajectRunTest.run_traject('ncsu', 'base')
    expect(result).not_to be_empty
  end

  it 'loads Duke spec without a problem' do
    spec = MarcToArgot::SpecGenerator.new('duke')
    result = spec.generate_spec
    expect(result['id']).to eq('001')
  end

  it 'generates base results for Duke' do
    result = TrajectRunTest.run_traject('duke', 'base', 'mrc')
    expect(result).not_to be_empty
  end

  it 'generates holdings data for Duke' do
    result = TrajectRunTest.run_traject('duke', 'holdings', 'mrc')
    expect(JSON.parse(result)['holdings']).to(
      eq(["{\"loc_b\":\"LAW\"," \
          "\"loc_n\":\"LGEN\"," \
          "\"notes\":[\"Currently received\"]," \
          "\"call_no\":\"KD135 .H3 4th\"," \
          "\"summary\":\"v.1-v.52; Current Statutes Service v.1-v.6 Noter Up Binder\"}"])
    )
  end

  it 'generates author_facet values for Duke' do
    result = TrajectRunTest.run_traject('duke', 'author_facet', 'mrc')
    expect(JSON.parse(result)['author_facet']).to(
      eq(["Author (100 field), 1874-1943",
          "Author (700 field, second indicator is 2), 1874-1943",
          "Author (700 field, no subfield e or 4), 1874-1943",
          "Author (700 field, subfield 4 value maps to creator) 1874-1943",
          "Author (700 field, subfield e allowable value) 1874-1943",
          "Author (700 field, t before g should display without g Value), 1874-1943",
          "Author (700 field, g before t should display with g Value) 1874-1943. Value",
          "Cornford, Francis Macdonald, 1874-1943"])
      )
  end

  it 'generates rollup_id for Duke' do
    result = TrajectRunTest.run_traject('duke', 'rollup_id', 'mrc')
    expect(JSON.parse(result)['rollup_id']).to(
      eq('OCLC12420922')
    )
  end

  it 'loads UNC spec without a problem' do
    spec = MarcToArgot::SpecGenerator.new('unc')
    result = spec.generate_spec
    expect(result['id']).to eq('907a')
  end

  it 'generates base results for UNC' do
    result = TrajectRunTest.run_traject('unc', 'base')
    expect(result).not_to be_empty
  end

  # test on b1082803
  b1082803argot = JSON.parse( TrajectRunTest.run_traject('unc', 'b1082803') )
  b1082803items = b1082803argot['items'][0]

  # test scope: shared config
  it 'generates author facet value if relators include punctuation' do
    expect(b1082803argot['author_facet']).to(
      include('Gregory, Lady, 1852-1932')
    )
  end

  # subsequent tests scope: unc config
  it 'sets item id for UNC (single item record)' do
    expect(b1082803items).to(
      include("\"id\":\"i1147335\"")
    )
  end

  it 'sets item loc_b and loc_n for UNC (single item record)' do
    expect(b1082803items).to(
      include("\"loc_b\":\"ddda\",\"loc_n\":\"ddda\"")
    )
  end

  it 'sets item status to Available for UNC (single item record)' do
    expect(b1082803items).to(
      include("\"status\":\"Available\"")
    )
  end

  it 'does NOT set item due date when status is Available for UNC (single item record)' do
    expect(b1082803items).not_to(
      include("\"due_date\":")
    )
  end

  it 'does NOT set item copy_no when it equals 1 for UNC (single item record)' do
    expect(b1082803items).not_to(
      include("\"copy_no\":")
    )
  end

  it 'sets item cn_scheme to LC when call_no is in 090 for UNC (single item record)' do
    expect(b1082803items).to(
      include("\"cn_scheme\":\"LC\"")
    )
  end

  it 'sets item call_no for normal LC for UNC (single item record)' do
    expect(b1082803items).to(
      include("\"call_no\":\"PB1423.C8 G7\"")
    )
  end

  # test on b3388632
  b3388632argot = TrajectRunTest.run_traject('unc', 'b3388632')
  b3388632result = JSON.parse(b3388632argot)['items'][0]

  it 'sets item cn_scheme to SUDOC when call_no is in 086 w/i1 = 0 for UNC (single item record)' do
    expect(b3388632result).to(
      include("\"cn_scheme\":\"SUDOC\"")
    )
  end

  # test on b7667969
  b7667969argot = TrajectRunTest.run_traject('unc', 'b7667969')
  b7667969result = JSON.parse(b7667969argot)['items'][0]

  it 'sets item cn_scheme to ALPHANUM when call_no is in 099 for UNC (single item record)' do
    expect(b7667969result).to(
      include("\"cn_scheme\":\"ALPHANUM\"")
    )
  end

  it 'sets item call_no (alphanumeric) from multiple subfield a values for UNC (single item record)' do
    expect(b7667969result).to(
      include("\"call_no\":\"J Villar\"")
    )
  end

  # test on b1319986
  b1319986argot = TrajectRunTest.run_traject('unc', 'b1319986')
  b1319986result0 = JSON.parse(b1319986argot)['items'][0]
  b1319986result1 = JSON.parse(b1319986argot)['items'][1]

  it 'sets item cn_scheme to LC when call_no is in 050 for UNC' do
    expect(b1319986result0).to(
      include("\"cn_scheme\":\"LC\"")
    )
  end

  it 'sets item vol for UNC' do
    expect(b1319986result0).to(
      include("\"vol\":\"Bd.2\"")
    )
  end

  it 'sets copy_no when greater than 1 for UNC' do
    expect(b1319986result1).to(
      include("\"copy_no\":\"2\"")
    )
  end

  #test on b4069204
  b4069204argot = TrajectRunTest.run_traject('unc', 'b4069204')
  b4069204result0 = JSON.parse(b4069204argot)['items'][0]

  it 'sets item cn_scheme to DDC when call_no is in 092 for UNC' do
    expect(b4069204result0).to(
      include("\"cn_scheme\":\"DDC\"")
    )
  end

  #test on b2975416
  b2975416argot = TrajectRunTest.run_traject('unc', 'b2975416')
  b2975416result = JSON.parse(b2975416argot)['items']

  it 'sets due date for UNC' do
    expect(b2975416result[1]).to(
      include("\"due_date\":\"2018-01-30\"")
    )
  end

  it 'sets status to Checked out for UNC' do
    expect(b2975416result[1]).to(
      include("\"status\":\"Checked out\"")
    )
  end

    it 'sets multiple item notes in correct order for UNC' do
    expect(b2975416result[1]).to(
      include("\"notes\":[\"zzTest note\",\"aaTest note\"]")
    )
  end

    it 'does NOT set item notes when there are none for UNC' do
    expect(b2975416result[0]).not_to(
      include("\"notes\":[]")
    )
    end

    it 'sets available to Available if status is In-Library Use Only for UNC' do
    expect(JSON.parse(b2975416argot)['available']).to(
      eq("Available")
    )
  end

    # it 'generates holdings data for UNC' do
  #   result = TrajectRunTest.run_traject('unc', 'holdings')
  #   expect(JSON.parse(result)['holdings']).to(
  #       eq(["{\"holdings_id\":\"c5125146\",\"loc_b\":\"UNC:Library "\
  #         "Service Center\",\"loc_n\":\"Library Service Center -- Use Request "\
  #         "Form\",\"summary\":\"v.42(1992)-v.45(1993)\"}"])
  #   )
  # end

end
