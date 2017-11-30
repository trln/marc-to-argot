require 'spec_helper'

describe MarcToArgot do
  it 'has a version number' do
    expect(MarcToArgot::VERSION).not_to be nil
  end

  it 'generates base results for NCSU' do
    result = Util::TrajectRunTest.run_traject('ncsu', 'base')
    expect(result).not_to be_empty
  end

  it 'generates base results for Duke' do
    result = Util::TrajectRunTest.run_traject('duke', 'base', 'mrc')
    expect(result).not_to be_empty
  end

  it 'generates holdings data for Duke' do
    result = Util::TrajectRunTest.run_traject('duke', 'holdings', 'mrc')
    expect(JSON.parse(result)['holdings']).to(
      eq(["{\"loc_b\":\"LAW\"," \
          "\"loc_n\":\"LGEN\"," \
          "\"notes\":[\"Currently received\"]," \
          "\"call_no\":\"KD135 .H3 4th\"," \
          "\"summary\":\"v.1-v.52; Current Statutes Service v.1-v.6 Noter Up Binder\"}"])
    )
  end

  it 'generates the location hierarchy for Duke' do
    result = Util::TrajectRunTest.run_traject('duke', 'holdings', 'mrc')
    expect(JSON.parse(result)['location_hierarchy']).to(
      eq(['duke', 'duke:dukelaww', 'law', 'law:lawdukw'])
    )
  end

  it 'generates author_facet values for Duke' do
    result = Util::TrajectRunTest.run_traject('duke', 'author_facet', 'mrc')
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

  it 'generates author facet value if relators include punctuation' do
    b1082803argot = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'b1082803') )
    expect(b1082803argot['author_facet']).to(
      include('Gregory, Lady, 1852-1932')
    )
  end

  it 'generates rollup_id for Duke' do
    result = Util::TrajectRunTest.run_traject('duke', 'rollup_id', 'mrc')
    expect(JSON.parse(result)['rollup_id']).to(
      eq('OCLC12420922')
    )
  end

  it 'does NOT generate a rollup_id for Duke special collections records' do
    result = Util::TrajectRunTest.run_traject('duke', 'special_collections', 'mrc')
    expect(JSON.parse(result)['rollup_id']).to(be_nil)
  end

  it 'generates base results for UNC' do
    result = Util::TrajectRunTest.run_traject('unc', 'base')
    expect(result).not_to be_empty
  end

  it 'generates record_data_source value for UNC' do
    b1082803argot = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'b1082803') )
    expect(b1082803argot['record_data_source']).to(
      eq(['ILSMARC'])
    )
  end

  it 'generates record_data_source value for Duke' do
    result = JSON.parse( Util::TrajectRunTest.run_traject('duke', 'rollup_id', 'mrc') )
    expect(result['record_data_source']).to(
      eq(['ILSMARC'])
    )
  end

end
