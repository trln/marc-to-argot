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

  let(:serialItem) { stringhash(loc_b: 'DHHILL', loc_n: 'STACKS', type: 'SERIAL') }

  let(:floatgameItem) { stringhash(loc_b: 'DHHILL', loc_n: 'FLOATGAME', type: 'GAME') }

  let(:gamelabItem) { stringhash(loc_b: 'HUNT', loc_n: 'GAMELAB', type: 'GAME-4HR') }

  let(:hillMonograph) { stringhash(loc_b: 'DHHILL', loc_n: 'STACKS', type: 'BOOK') }

  let(:hillReserve) { stringhash(loc_b: 'DHHILL', loc_n: 'STACKS', loc_current: 'RESERVES') }

  let(:hillReference) { stringhash(loc_b: 'DHHILL', loc_n: 'REF', type: 'BOOKNOCIRC') }

  let(:fixture_items) { yaml_to_item_fields('ncsu', 'items') }

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

  let(:no_vetmed_records) { load_json_multiple(run_traject('ncsu', 'base')) }

  context 'NCSU' do
    it 'has a blank copy_no' do
      expect(marc_to_item(copy_no_item)['copy_no']).to eq('')
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

    it 'maps serials as library use only' do
      expect(library_use_only?(serialItem)).to be(true)
    end

    it 'tags reserves as current_as_home' do
      remap_item_locations!(hillReserve)
      expect(hillReserve['loc_n']).to eq('RESERVES')
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
      expect(marc_to_item(xx_call_no_item)['call_no']).to eq('')
    end

    it 'does not output item notes' do
      expect(marc_to_item(item_note_item)['notes']).to be_nil
    end

    it 'removes item notes' do
      item = JSON.parse(item_with_notes_record['items'].first)
      expect(item['notes']).to be_nil
    end
  end
end
