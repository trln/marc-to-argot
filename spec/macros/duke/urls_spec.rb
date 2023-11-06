require 'spec_helper'

describe MarcToArgot::Macros::Duke::Urls do
  include described_class

  let(:restricted) { run_traject_json('duke', 'restricted', 'xml') }
  let(:unproxied_restricted) { run_traject_json('duke', 'unproxied_restricted', 'xml') }
  let(:open_access) { run_traject_json('duke', 'open_access', 'xml') }
  let(:dc_urls) { run_traject_json('duke', 'dc_urls', 'xml') }
  let(:link_in_subfield_a) { run_traject_json('duke', 'link_in_subfield_a', 'xml') }

  context 'Duke' do
    it 'restricted is not set to false for fulltext URLs with the proxy prefix' do
      expect(JSON.parse(restricted['url'][0])['restricted']).to be_nil
    end

    it 'does not set restricted to false when an unproxied "Restricted" URL is detected' do
      expect(JSON.parse(unproxied_restricted['url'][0])['restricted']).to be_nil
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

    it 'sets the href value from subfield a if there is no subfield u' do
      expect(JSON.parse(link_in_subfield_a['url'][0])['href']).to(
        eq('https://library.fuqua.duke.edu/fuquaonly/capiqreg.htm')
      )
    end
  end
end
