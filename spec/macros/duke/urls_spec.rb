require 'spec_helper'

describe MarcToArgot::Macros::Duke::Urls do
  include described_class

  let(:needs_proxy) { run_traject_json('duke', 'needs_proxy', 'xml') }
  let(:open_access) { run_traject_json('duke', 'open_access', 'xml') }
  let(:dc_urls) { run_traject_json('duke', 'dc_urls', 'xml') }
  let(:open_access_exception) { run_traject_json('duke', 'open_access_exception', 'xml') }
  let(:link_in_subfield_a) { run_traject_json('duke', 'link_in_subfield_a', 'xml') }

  context 'Duke' do
    it 'does not add a proxy prefix to restricted, fulltext URLs' do
      expect(JSON.parse(needs_proxy['url'][0])['href']).to(
        eq('http://site.ebrary.com/lib/dukelibraries/docDetail.action?docID=11017131')
      )
    end

    it 'sets restricted to false for open access URLs' do
      expect(JSON.parse(open_access['url'][0])['restricted']).to(
        eq('false')
      )
    end

    it 'sets restricted to false for digital collections URLs' do
      expect(JSON.parse(dc_urls['url'][0])['restricted']).to(
        eq('false')
      )
    end

    it 'does not add a proxy prefix to open access exception matches' do
      expect(JSON.parse(open_access_exception['url'][0])['href']).to(
        eq('https://ropercenter.cornell.edu')
      )
    end

    it 'sets the href value from subfield a if there is no subfield u' do
      expect(JSON.parse(link_in_subfield_a['url'][0])['href']).to(
        eq('https://library.fuqua.duke.edu/fuquaonly/capiqreg.htm')
      )
    end
  end
end
