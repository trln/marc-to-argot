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

      # FOURTHFLOORCLOSURE
      context '#hill_fourth_floor?' do
        it 'tags book with BC call number on fourth floor' do
          fourth = fixture_items[:fourth_floor_item]
          expect(hill_fourth_floor?(fourth)).to be(true)
          expect(fourth['status']).to include("Available upon request")
        end

        it 'tags book with EB call number as not on fourth floor' do
          expect(hill_fourth_floor?(fixture_items[:fifth_floor_item])).to be(false)
          expect(fixture_items[:fifth_floor_item]['status']).to eq('Available')
        end

        it 'tags Hunt book with BC call number as not on Hill fourth floor' do
          expect(hill_fourth_floor?(fixture_items[:hunt_ff_range_item])).to be(false)
          expect(fixture_items[:hunt_ff_range_item]['status']).to eq('Available')
        end



      end
    end
  end
end
