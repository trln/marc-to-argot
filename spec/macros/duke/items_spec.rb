require 'spec_helper'

describe MarcToArgot::Macros::Duke::Items do
  include described_class
  let(:item_sort) { run_traject_json('duke', 'item_sort', 'xml') }
  let(:rec_with_holding) { run_traject_json('duke', 'record_with_holding', 'xml') }
  let(:single_holding_one_status) { run_traject_json('duke', 'single_holding_one_status') }
  let(:multi_holdings_multi_status) { run_traject_json('duke', 'multi_holdings_multi_status') }
  let(:multi_holdings_no_status) { run_traject_json('duke', 'multi_holdings_no_status') }

  context 'Duke' do
    it 'puts items in a sensible order' do
      expect(JSON.parse(item_sort['items'][1])['copy_no']).to(
        eq("Box 2")
      )
    end

    it 'extracts items (940, no \'x\' subfield)' do
      result = run_traject_json('duke', 'items', 'mrc')
      expect(result['items']).to(
        eq(["{\"loc_b\":\"PERKN\",\"loc_n\":\"PK\",\"cn_scheme\":\"LC\",\"call_no\":\"DF229.T6 C8 1969\","\
            "\"copy_no\":\"c.1\",\"type\":\"BOOK\",\"item_id\":\"D03223637Q\",\"status\":\"\"}"])
      )
    end

    it 'extracts holdings' do
      expect(rec_with_holding['holdings']).to(
        eq(["{\"status\":\"Unavailable\",\"loc_b\":\"PERKN\",\"loc_n\":\"PK\",\"holding_id\":\"22912285300008501\","\
            "\"call_no\":\"PR9619.4.M38355 H54 2024\",\"summary\":\"\"}"])
      )
    end

    it 'correctly sets holding status based on 852x' do
      rec = make_rec
      rec << MARC::DataField.new('852', '0', ' ',
                                ['b', 'PERKN'],
                                ['x', 'Unavailable']
                                )
      result = run_traject_on_record('duke', rec)
      expect(JSON.parse(result['holdings'][0])['status']).to(
        eq("Unavailable")
      )
    end

    it 'correctly sets doc-level "available" value for record, 1 holding that is available' do
      expect(single_holding_one_status['available']).to(
        eq('Available')
      )
    end

    it 'sets doc-level "available" value for multi-holding + multi-status per holding record' do
      expect(multi_holdings_multi_status['available']).to(
        eq('Available')
      )
    end

    it 'does not set doc-level "available" no holdings are available' do
      expect(multi_holdings_no_status['available']).to be_nil
    end

    it 'sets the cn_scheme' do
      rec = make_rec
      rec << MARC::DataField.new('940', ' ', ' ',
                                 ['d', '0'],
                                 ['h', 'Some Call Number'])
      rec << MARC::DataField.new('940', ' ', ' ',
                                 ['d', '1 '],
                                 ['h', 'Some Call Number'])
      rec << MARC::DataField.new('940', ' ', ' ',
                                 ['d', ' '],
                                 ['h', 'Some Call Number'])
      result = run_traject_on_record('duke', rec)['items']
      expect(result).to(
        eq(['{"cn_scheme":"LC","call_no":"Some Call Number","status":""}',
            '{"cn_scheme":"DDC","call_no":"Some Call Number","status":""}',
            '{"call_no":"Some Call Number","status":""}',])
      )
    end

    it 'sets the status when 9'

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

    # DEPRECATED (see 'extract holdings' above)
    # it 'generates holdings data' do
    #   result = run_traject_json('duke', 'holdings', 'mrc')
    #   expect(result['holdings']).to(
    #     eq(["{\"loc_b\":\"LAW\"," \
    #         "\"loc_n\":\"LGEN\"," \
    #         "\"notes\":[\"Currently received\"]," \
    #         "\"call_no\":\"KD135 .H3 4th\"," \
    #         "\"summary\":\"Holdings: v.1-v.52; Supplements: Current Statutes Service v.1-v.6 Noter Up Binder\"}"])
    #   )
    # end

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
