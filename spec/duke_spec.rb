require 'spec_helper'

describe MarcToArgot do
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
end
