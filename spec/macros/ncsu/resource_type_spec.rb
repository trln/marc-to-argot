# frozen_string_literal: true

describe MarcToArgot::Macros::NCSU::ResourceType do
  context 'when fixed fields determine resource type' do
    let(:music) { run_traject_json('ncsu', 'music-recording') }
    let(:ejournal) { run_traject_json('ncsu', 'ejournal') }
    let(:non_musical_sound_recording) { run_traject_json('ncsu', 'non-musical-sound-recording') }

    it 'correctly detects music recording' do
      expect(music['resource_type']).to eq(['Music recording'])
    end

    it 'correctly detects an ejournal as a journal' do
      expect(ejournal['resource_type']).to eq(['Journal, Magazine, or Periodical'])
    end

    it 'correctly detects a non-musical sound recording' do
      # it can't also be an audiobook!
      expect(non_musical_sound_recording['resource_type']).to eq(['Non-musical sound recording'])
    end


  end

  context 'item type-based' do
    let(:archival) { run_traject_json('ncsu', 'archival_material') }
    let(:audiobook) { run_traject_json('ncsu', 'audiobook') }

    it 'correctly detects archival materials' do
      expect(archival['resource_type']).to eq(['Archival and manuscript material'])
    end

    it 'correct detects an audiobook' do
      expect(audiobook['resource_type']).to eq(['Audiobook'])
    end
  end

  context 'govdocs (itemcat2 == FEDDOC)' do
    let(:govdoc) { run_traject_json('ncsu', 'govdoc') }

    it 'correctly detects a govdoc' do
      expect(govdoc['resource_type']).to include('Government publication')
    end
  end
end
