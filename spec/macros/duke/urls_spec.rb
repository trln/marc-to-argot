require 'spec_helper'

describe MarcToArgot::Macros::Duke::Urls do
  include described_class

  let(:needs_proxy) { run_traject_json('duke', 'needs_proxy', 'xml') }
  let(:open_access) { run_traject_json('duke', 'open_access', 'xml') }

  context 'Duke' do
    it 'adds a proxy prefix to restricted, fulltext URLs' do
      expect(JSON.parse(needs_proxy['url'][0])['href']).to(
        eq('https://proxy.lib.duke.edu/login?url='\
          'http://site.ebrary.com/lib/dukelibraries/docDetail.action?docID=11017131')
      )
    end

    it 'sets restricted to false for open access URLs' do
      expect(JSON.parse(open_access['url'][0])['restricted']).to(
        eq('false')
      )
    end
  end
end
