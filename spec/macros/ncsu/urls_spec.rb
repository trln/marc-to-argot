require 'spec_helper'

describe MarcToArgot::Macros do
  # convenience sym->str for keys
  def stringhash(m)
    Hash[m.map { |k, v| [k.to_s, v] }]
  end

  let(:open_access_record) { run_traject_json('ncsu', 'open_access_ejournal') }
  let(:ejournal) { run_traject_json('ncsu', 'ejournal') }
  let(:url_note_record) { run_traject_json('ncsu', 'audiobook') }
  let(:multiple_url_note_record) { run_traject_json('ncsu', 'multiple-856-notes') }
  let(:empty_url_note_record) { run_traject_json('ncsu', 'empty-856-notes') }

  let(:ejournal_with_856) { run_traject_json('ncsu', 'ejournal_with_856') }

  context 'NCSU' do
    it 'outputs restricted=false if there is an 856 and online and open access' do
      urls = open_access_record['url'].map { |u| JSON.parse(u) }
      # filter out run time added journals links
      urls.reject { |u| u['text'] == 'View available online access' }.each do |u|
        expect(u['restricted']).to be false
      end
    end

    it 'should not output restricted field if not an open access url' do
      urls = ejournal['url'].map { |u| JSON.parse(u) }
      urls.each do |u|
        expect(u['restricted']).to be nil
      end
    end

    it 'should output url note from the 856$z field' do
      url = url_note_record['url'].map { |u| JSON.parse(u) }.first
      expect(url['note']).to eq('Available to participating NC libraries through NC LIVE.')
    end

    it 'should concatenate multiple 856$3$z fields to url note' do
      url = multiple_url_note_record['url'].map { |u| JSON.parse(u) }.first
      expect(url['note']).to eq("Gale Cengage Learning, Smithsonian Collections Online: World's Fairs and Expositions: Visions of Tomorrow; Gale Cengage Learning")
    end

    it 'should not output url["note"] when 856$3$z are empty' do
      url = empty_url_note_record['url'].map { |u| JSON.parse(u) }.first
      expect(url['note']).to be_nil
    end

    context 'Journals' do 

      it 'should only output a link to journals if 856 is present' do
        local_id = ejournal_with_856['local_id']['value']
        urls = ejournal_with_856['url'].map { |u| JSON.parse(u) }
        expect(ejournal['institution']).to eq(['ncsu'])
        expect(urls.length).to eq(1)
        expect(urls.first['href']).to include("catkey=#{local_id}")
      end
    end
  end
end
