require 'spec_helper'

# include MarcToArgot::Macros::Duke::Urls

describe MarcToArgot::Macros::Duke::Urls do
  include described_class

  let(:restricted) { run_traject_json('duke', 'restricted', 'xml') }
  let(:unproxied_restricted) { run_traject_json('duke', 'unproxied_restricted', 'xml') }
  let(:open_access) { run_traject_json('duke', 'open_access', 'xml') }
  let(:dc_urls) { run_traject_json('duke', 'dc_urls', 'xml') }
  let(:link_in_subfield_a) { run_traject_json('duke', 'link_in_subfield_a', 'xml') }
  let(:url_943_journal_case) { run_traject_json('duke', 'url_943_journal_case', 'xml') }
  let(:url_943_newspaper_case) { run_traject_json('duke', 'url_943_newspaper_case', 'xml') }

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

    context '943 fields:' do
      it 'sets url_type to \'fulltext\' when processing 943 fields' do
        expect(JSON.parse(url_943_journal_case['url'][0])['type']).to(
          eq('fulltext')
        )
      end

      it 'has a url that includes \'duke.userservices.exlibrisgroup\'' do
        expect(JSON.parse(url_943_journal_case['url'][0])['href']).to(
          include('duke.userservices.exlibrisgroup')
        )
      end

      it 'does not include a URL when 943$s has a value of "Not Available"' do
        rec = make_rec
        rec << MARC::DataField.new('943', '0', ' ',
                                  ['s', 'Not Available']
                                  )
        result = run_traject_on_record('duke', rec)
        expect(result['url']).not_to be
      end
    end

    context '944 fields:' do
      it 'correctly detects a MARC 944 field and sets the URL correctly' do
        rec = make_rec
        rec << MARC::DataField.new('944', '0', ' ',
                                  ['b', '61903212100008501']
                                  )
        result = run_traject_on_record('duke', rec)
        expect(JSON.parse(result['url'][0])['href']).to(
          include('61903212100008501')
        )
      end
    end
  end
end
