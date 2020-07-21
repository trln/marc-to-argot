require 'spec_helper'

describe MarcToArgot::Macros::NCSU::Items do
  include described_class

  # convenience sym->str for keys
  def stringhash(m)
    Hash[m.map { |k, v| [k.to_s, v] }]
  end

  let(:speccollItem) { { 'loc_b' => 'SPECCOLL', 'loc_n' => 'ARCHIVES' } }

  let(:textbookItem) { { 'loc_b' => 'HUNT', 'loc_n' => 'TEXTBOOK' } }

  let(:lrlTextbookItem) { { 'loc_b' => 'LRL', 'loc_n' => 'TEXTBOOK'} }

  let(:bookbotStacksItem) { { 'loc_b' => 'BOOKBOT', 'loc_n' => 'STACKS' } }

  let(:floatgameItem) { stringhash(loc_b: 'DHHILL', loc_n: 'FLOATGAME', type: 'GAME') }

  let(:gamelabItem) { stringhash(loc_b: 'HUNT', loc_n: 'GAMELAB', type: 'GAME-4HR') }

  let(:hillMonograph) { stringhash(loc_b: 'DHHILL', loc_n: 'STACKS', type: 'BOOK') }

  let(:hillReserve) { stringhash(loc_b: 'DHHILL', loc_n: 'STACKS', loc_current: 'RESERVES') }

  let(:hillReference) { stringhash(loc_b: 'DHHILL', loc_n: 'REF', type: 'BOOKNOCIRC') }

  let(:item_on_hold) { stringhash(loc_b: 'DHHILL', loc_n: 'STACKS', loc_current: 'HOLDS') }

  let(:item_on_reserve) { stringhash(loc_b: 'DHHILL', loc_n: 'TEXTBOOK', type: 'COREBOOK') }

  let(:kindle_item) { stringhash(loc_b: 'DHHILL', loc_n: 'STACKS', type: 'EBOOK') }

  let(:fixture_items) do 
    yaml_to_item_fields('ncsu', 'items').each_with_object({}) do |(k, v), h|
      h[k] = marc_to_item(v)
    end
  end

  let(:copy_no_item) { fixture_items[:copy_no] }

  let(:no_copy_no_item) { fixture_items[:no_copy_no] }

  let(:xx_call_no_item) { fixture_items[:xx_no] }

  let(:item_note_item) { fixture_items[:item_note] }

  let(:bbr_record) { run_traject_json('ncsu', 'bbr') }

  let(:audiobook_record) { run_traject_json('ncsu', 'audiobook') }

  let(:xx_call_no_record) { run_traject_json('ncsu', 'xx_call_no_audiobook') }

  let(:open_access_record) { run_traject_json('ncsu', 'open_access_ejournal') }

  let(:item_with_notes_record) { run_traject_json('ncsu', 'music-recording-with-notes') }

  let(:vetmed) { run_traject_json('ncsu', 'vetmed-location-hsl') }

  let(:bookbot_oversize) { run_traject_json('ncsu', 'bookbot-oversize') }

  let(:speccoll_offsite_manuscript) { run_traject_json('ncsu', 'manuscript') }

  let(:govdoc) { run_traject_json('ncsu', 'govdoc') }

  let(:no_vetmed_records) { load_json_multiple(run_traject('ncsu', 'base')) }

  let(:metrc_reserve) { fixture_items[:metrc_reserve ] }


  let (:dwell_sorted_call_numbers) { [
    "TH4805 .D88 V.2 NO.3-5 2002", "TH4805 .D88 V.2 NO.6 2002", "TH4805 .D88 V.3 NO.1-3 2002-2003", 
    "TH4805 .D88 V.3 NO.4,6,8 2003", "TH4805 .D88 V.3 NO.5,7 2003", "TH4805 .D88 V.4 NO.1-2 2003", 
    "TH4805 .D88 V.4 NO.4-5,7 2004", "TH4805 .D88 V.4 NO.8 2004", "TH4805 .D88 V.5 NO.1 2004", 
    "TH4805 .D88 V.5 NO.2 2004", "TH4805 .D88 V.5 NO.4,6-7 2005", "TH4805 .D88 V.5 NO.5 2004", 
    "TH4805 .D88 V.5 NO.8 2005", "TH4805 .D88 V.6 NO.1-2 2005-2006", "TH4805 .D88 V.6 NO.3 2006", 
    "TH4805 .D88 V.6 NO.9 2006", "TH4805 .D88 V.7 NO.2 2006-2007", "TH4805 .D88 V.7 NO.6 2007", 
    "TH4805 .D88 V.7 NO.8-10 2007", "TH4805 .D88 V.8 NO.1-3 2007-2008", "TH4805 .D88 V.8 NO.4-6 2008", 
    "TH4805 .D88 V.8 NO.7-10 2008", "TH4805 .D88 V.9 NO.1-3 2008-2009", "TH4805 .D88 V.9 NO.4-6 2009",
    "TH4805 .D88 V.9 NO.7-10 2009", "TH4805 .D88 V.10 NO.1-2,4-5 2009-2010", "TH4805 .D88 V.10 NO.6-10 2010", 
    "TH4805 .D88 V.10 SUPPL 2010", "TH4805 .D88 V.11 NO.1-5 2010-2011", "TH4805 .D88 V.11 NO.6-10 2011", 
    "TH4805 .D88 V.11 SUPPL. 2011", "TH4805 .D88 V.12 NO.1-5 2011-2012", "TH4805 .D88 V.12 NO.6-10 2012", 
    "TH4805 .D88 V.13 NO.1-5 2013 SUPPL.", "TH4805 .D88 V.13 NO.6-10 2013", "TH4805 .D88 V.14 NO.1-5 2013-2014", 
    "TH4805 .D88 V.14 NO.6-11 2014", "TH4805 .D88 V.15 NO.1-5 2014-2015", "TH4805 .D88 V.15 NO.6-10 2015", 
    "TH4805 .D88 V.16 NO.1-5 2015-2016", "TH4805 .D88 V.16 NO.6-10 2016", "TH4805 .D88 V.16 NO.11 2016", 
    "TH4805 .D88 V.17 NO.1-3 2017", "TH4805 .D88 V.17 NO.4-6 2017", "TH4805 .D88 V.18 NO.1-3 2018"
    ]
  }

  let (:dwell) { run_traject_json('ncsu', 'dwell') }

  context 'NCSU' do
    it 'has a blank copy_no' do
      expect(copy_no_item['copy_no']).to eq('')
    end

    it 'does not tag BOOKBOT/STACKS as library_use_only' do
      expect(library_use_only?(bookbotStacksItem)).to be(false)
    end

    it 'correctly detects HUNT/TEXTBOOK virtual collections' do
      expect(virtual_collection(textbookItem)).to eq('TEXTBOOK')
    end

    it 'does not put LRL/TEXTBOOK into a virtual collection' do
      expect(virtual_collection(lrlTextbookItem)).to be(false)
    end

    it 'maps FLOATGAME item to a virtual collection' do
      expect(virtual_collection(floatgameItem)).to eq('FLOATGAME')
    end

    it 'maps special collections as library use only' do
      expect(library_use_only?(speccollItem)).to be(true)
    end

    it 'tags reserves as current_as_home' do
      remap_item_locations!(hillReserve)
      expect(hillReserve['loc_n']).to eq('RESERVES')
    end

    it 'change loc_b,loc_n to Hunt,Bookbot for items in bookbot library' do
      item = JSON.parse(bookbot_oversize['items'].first)
      expect(item['loc_b']).to match(/hunt/i)
      expect(item['loc_n']).to match(/bookbot/i)
    end

    it 'alternate way to catch reserve items to change their status' do
      item_status!(item_on_reserve)
      expect(item_on_reserve['status']).to match(/available - on reserve/i)
    end

    it 'change status for kindle items' do
      item_status!(kindle_item)
      expect(kindle_item['status']).to match(/available - libraries kindle only/i)
    end

    it 'adds library use only to reference/booknocirc item' do
      expect(item_status!(hillReference)).to match(/library use only/i)
    end

    it 'adds library use only to status for game in gamelab' do
      expect(item_status!(gamelabItem)).to match(/library use only/i)
    end

    it 'does not add library use only to a standard monograph' do
      expect(item_status!(hillMonograph)).not_to match(/library use only/i)
    end

    it 'returns On Hold for items with loc_current as HOLDS' do
      item_status!(item_on_hold)
      expect(item_on_hold['status']).to match(/on hold/i)
    end

    it 'correctly tags HSL location for VETMED' do
      expect(vetmed['location_hierarchy']).to include('hsl')
      expect(vetmed['location_hierarchy']).to include('hsl:hslncsuvetmed')
    end

    it 'does not tag HSL location when no VETMED' do
      aggregate_failures 'records without VETMED items' do
        no_vetmed_records.each do |rec|
          expect(rec['location_hierarchy']).not_to include('hsl')
          expect(rec['location_hierarchy']).not_to include('hsl:hslncsuvetmed')
        end
      end
    end

    it 'munges bookBot item locations' do
      remap_item_locations!(bookbotStacksItem)
      expect(bookbotStacksItem['loc_b']).to eq('HUNT')
      expect(bookbotStacksItem['loc_n']).to eq('BOOKBOT')
    end

    it 'munges narrow location for SPECCOLL' do
      remap_item_locations!(speccollItem)
      expect(speccollItem['loc_n']).to eq('SPECCOLL-ARCHIVES')
    end

    it 'excludes PRINTDDA (Books By Request) from location hierarchy' do
      lh = bbr_record['location_hierarchy']
      expect(lh).not_to include('ncsu:BBR')
    end

    it 'excludes ONLINE library from location hierarchy' do
      expect(audiobook_record['location_hierarchy']).to be_empty
    end

    it 'outputs empty string for call_no when call_no begins with XX' do
      item = JSON.parse(xx_call_no_record['items'].first)
      expect(item['call_no']).to eq('')
    end

    it 'outputs empty string for xx call_no' do
      expect(xx_call_no_item['call_no']).to eq('')
    end

    it 'does not output item notes' do
      expect(item_note_item['notes']).to be_nil
    end

    it 'removes item notes' do
      item = JSON.parse(item_with_notes_record['items'].first)
      expect(item['notes']).to be_nil
    end

    it 'offsite items have status available upon request' do
      item = JSON.parse(speccoll_offsite_manuscript['items'].first)
      expect(item['status']).to include('Available upon request')
    end

    it 'bookbot items have status available upon request' do
      item = JSON.parse(govdoc['items'].first)
      expect(item['status']).to include('Available upon request')
    end

    context 'remamp_item_locations!' do 
      it 'shows LRL (METRC) reserves as being at METRC' do 
        expect(metrc_reserve['loc_b']).not_to eq('LRL')
        remap_item_locations!(metrc_reserve)
        expect(metrc_reserve['loc_b']).to eq('LRL')
      end
    end

    # test that we call sort_items from ItemUtils at the right
    # time to ensure they're sorted in the output
    context 'item extraction' do
      it 'sorts jumbled Dwell items' do
        actual_call_numbers = dwell['items'].map { |i| JSON.parse(i)['call_no'] }
        expect(actual_call_numbers).to eq(dwell_sorted_call_numbers)
      end
    end

    context 'Serials' do
      context '#library_use_only?' do

        it 'marks serial at DESIGN as library use only' do
          expect(library_use_only?(fixture_items[:design_serial])).to be(true)
        end

        it 'marks serial at Hill as circulatable' do
          expect(library_use_only?(fixture_items[:hill_serial])).to be(false)
        end

        it 'marks serial at Hunt as circulatable' do
          expect(library_use_only?(fixture_items[:hunt_serial])).to be(false)
        end
      end
     
      context 'Status' do
        it 'marks Design serial as Library use only' do
          expect(fixture_items[:design_serial]['status']).to include('Library use only')
        end
      end
    end
  end
end
