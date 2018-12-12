require 'spec_helper'

describe MarcToArgot::Macros::Duke::Items do
  include described_class
  let(:item_sort) { run_traject_json('duke', 'item_sort', 'xml') }

  context 'Duke' do
    it 'puts items in a sensible order' do
      expect(JSON.parse(item_sort['items'][1])['copy_no']).to(
        eq("Box 2")
      )
    end

    it 'extracts items' do
      result = run_traject_json('duke', 'items', 'mrc')
      expect(result['items']).to(
        eq(["{\"loc_b\":\"PERKN\",\"loc_n\":\"PK\",\"cn_scheme\":\"LC\",\"call_no\":\"DF229.T6 C8 1969\","\
            "\"copy_no\":\"c.1\",\"type\":\"BOOK\",\"item_id\":\"D03223637Q\",\"status\":\"Available\"}"])
      )
    end

    it 'extracts barcodes' do
      result = run_traject_json('duke', 'items', 'mrc')
      expect(result['barcodes']).to(
        eq(["D03223637Q"])
      )
    end

    it 'generates holdings data' do
      result = run_traject_json('duke', 'holdings', 'mrc')
      expect(result['holdings']).to(
        eq(["{\"loc_b\":\"LAW\"," \
            "\"loc_n\":\"LGEN\"," \
            "\"notes\":[\"Currently received\"]," \
            "\"call_no\":\"KD135 .H3 4th\"," \
            "\"summary\":\"v.1-v.52; Current Statutes Service v.1-v.6 Noter Up Binder\"}"])
      )
    end

    it 'generates the location hierarchy' do
      result = run_traject('duke', 'holdings', 'mrc')
      expect(JSON.parse(result)['location_hierarchy']).to(
        eq(['duke', 'duke:dukelaww', 'law', 'law:lawdukw'])
      )
    end
  end
end
