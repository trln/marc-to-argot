require 'spec_helper'

describe MarcToArgot::Macros do
  # convenience sym->str for keys
  def stringhash(m)
    Hash[m.map { |k, v| [k.to_s, v] }]
  end

  let(:open_access_record) { run_traject_json('ncsu', 'open_access_ejournal') }

  context 'NCSU' do
    it 'outputs restricted=false if there is an 856 and online and open access' do
      urls = open_access_record['url'].map { |u| JSON.parse(u) }
      # filter out run time added journals links
      urls.reject { |u| u['text'] == 'View available online access' }.each do |u|
        expect(u['restricted']).to be false
      end
    end
  end
end
