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
  end
end
