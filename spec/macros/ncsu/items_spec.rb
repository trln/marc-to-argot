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

  context 'NCSU' do
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

    it 'munges bookBot item locations' do
      remap_item_locations!(bookbotStacksItem)
      expect(bookbotStacksItem['loc_b']).to eq('HUNT')
      expect(bookbotStacksItem['loc_n']).to eq('BOOKBOT')
    end

    it 'munges narrow location for SPECCOLL' do
      remap_item_locations!(speccollItem)
      expect(speccollItem['loc_n']).to eq('SPECCOLL-ARCHIVES')
    end
  end
end
