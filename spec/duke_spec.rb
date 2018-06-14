require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest

  it '(Duke) extracts items' do
    result = run_traject_json('duke', 'items', 'mrc')
    expect(result['items']).to(
      eq(["{\"loc_b\":\"PERKN\",\"loc_n\":\"PK\",\"cn_scheme\":\"LC\",\"call_no\":\"DF229.T6 C8 1969\","\
          "\"copy_no\":\"c.1\",\"type\":\"BOOK\",\"item_id\":\"D03223637Q\",\"status\":\"Available\"}"])
    )
  end

  it '(Duke) extracts barcodes' do
    result = run_traject_json('duke', 'items', 'mrc')
    expect(result['barcodes']).to(
      eq(["D03223637Q"])
    )
  end

  it '(Duke) generates holdings data' do
    result = run_traject_json('duke', 'holdings', 'mrc')
    expect(result['holdings']).to(
      eq(["{\"loc_b\":\"LAW\"," \
          "\"loc_n\":\"LGEN\"," \
          "\"notes\":[\"Currently received\"]," \
          "\"call_no\":\"KD135 .H3 4th\"," \
          "\"summary\":\"v.1-v.52; Current Statutes Service v.1-v.6 Noter Up Binder\"}"])
    )
  end

  it '(Duke) generates the location hierarchy' do
    result = run_traject('duke', 'holdings', 'mrc')
    expect(JSON.parse(result)['location_hierarchy']).to(
      eq(['duke', 'duke:dukelaww', 'law', 'law:lawdukw'])
    )
  end

  it '(Duke) generates rollup_id' do
    result = run_traject_json('duke', 'rollup_id', 'mrc')
    expect(result['rollup_id']).to(
      eq('OCLC12420922')
    )
  end

  it '(Duke) does NOT generate a rollup_id for Duke special collections records' do
    result = run_traject_json('duke', 'special_collections', 'mrc')
    expect(result['rollup_id']).to(be_nil)
  end
end
