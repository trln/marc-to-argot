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

    it 'extracts and normalizes call numbers' do
      result = run_traject_json('duke', 'items_bound_with')
      expect(result['lc_call_nos_normed']).to(
        eq(['PN.6349.G43.1556', 'PQ.4623.G82.D45--15550012MO'])
      )
    end

    it 'extracts shelving control numbers' do
      result = run_traject_json('duke', 'item_shelf_number')
      expect(result['shelf_numbers']).to(
        eq(['DVD 4176'])
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

    it 'keeps all the items even when they have the same call number' do
      result = run_traject('duke', 'multi-items-same-cn', 'xml')
      expect(JSON.parse(result)['items'].length).to eq(8)
    end
  end
end
