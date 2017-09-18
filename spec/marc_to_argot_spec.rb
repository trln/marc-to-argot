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
      eq(["{\"library\":\"LAW\"," \
          "\"location\":\"LGEN\"," \
          "\"notes\":[\"Currently received\"]," \
          "\"call_number\":\"KD135 .H3 4th\"," \
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

  it 'loads UNC spec without a problem' do
    spec = MarcToArgot::SpecGenerator.new('unc')
    result = spec.generate_spec
    expect(result['id']).to eq('907a')
  end

  it 'generates base results for UNC' do
    result = TrajectRunTest.run_traject('unc', 'base')
    expect(result).not_to be_empty
  end

  it 'generates holdings data for UNC' do
    result = TrajectRunTest.run_traject('unc', 'holdings')
    expect(JSON.parse(result)['holdings']).to(
        eq(["{\"record_id\":\"c5125146\",\"library\":\"UNC:Library "\
          "Service Center\",\"location\":\"Library Service Center -- Use Request "\
          "Form\",\"summary\":\"v.42(1992)-v.45(1993)\"}"])
    )
  end

end
