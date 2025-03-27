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
  let(:url_943_non_journal_case) { run_traject_json('duke', 'url_943_non_journal_case', 'xml') }
  let(:soa_url) {
    data_dir = File.expand_path('../../../lib/data',File.dirname(__FILE__))
    soa_url_conf = YAML.load_file("#{data_dir}/duke/soa_url_conf.yml")
    soa_url_conf['soa_url']
  }

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

    context 'SOA URL:' do
      it 'correctly loads the :soa_url from YAML' do
        expect(soa_url).to be
      end
    end

    # For this spec, we're using a record that represents a 943 field from Alma
    # that has a 'raw href' from the 943d, and is expected to be changed.
    context 'MARC 943 - general tests' do
      it 'sets the marc_source to 943' do
        parsed_url = JSON.parse(url_943_journal_case['url'][0])
        expect(parsed_url['marc_source']).to match('943')
      end

      it 'sets url_type to \'fulltext\' when processing 943 fields' do
        expect(JSON.parse(url_943_journal_case['url'][0])['type']).to(
          eq('fulltext')
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

    context 'MARC 943: JOURNAL e-resources' do
      it 'includes \'soa_url\' in href value' do
        parsed_url = JSON.parse(url_943_journal_case['url'][0])
        expect(parsed_url['href']).to include(soa_url)
      end

      it 'sets the href value to correct \'soa_url\'' do
        parsed_url = JSON.parse(url_943_journal_case['url'][0])
        expect(parsed_url['href']).to match("#{soa_url}#{parsed_url['portfolio_id']}")
      end

      it 'changes the URL href correctly when original URL include \'na05-psb\'' do
        rec = make_rec
        rec << MARC::DataField.new('943', '0', ' ',
                                  ['d', 'https://na05-psb.alma.exlibrisgroup.com/view/uresolver/01DUKE_INST/openurl?u.ignore_date_coverage=true&amp;portfolio_pid=53880950230008501&amp;Force_direct=true'],
                                  ['q', 'JOURNAL'],
                                  ['8', '53880950230008501']
                                  )
        result = run_traject_on_record('duke', rec)
        parsed_url = JSON.parse(result['url'][0])
        expect(parsed_url['href']).to match("#{soa_url}#{parsed_url['portfolio_id']}")
      end

      it 'does not set \'restricted: false\'' do
        parsed_url = JSON.parse(url_943_journal_case['url'][0])
        expect(parsed_url['restricted']).to be_nil
      end
    end

    context 'MARC 943: NEWSPAPER e-resources' do
      it 'includes \'soa_url\' in href value' do
        parsed_url = JSON.parse(url_943_newspaper_case['url'][0])
        expect(parsed_url['href']).to include(soa_url)
      end

      it 'sets the href value to correct \'soa_url\'' do
        parsed_url = JSON.parse(url_943_newspaper_case['url'][0])
        expect(parsed_url['href']).to match("#{soa_url}#{parsed_url['portfolio_id']}")
      end

      it 'does not set \'restricted: false\'' do
        parsed_url = JSON.parse(url_943_newspaper_case['url'][0])
        expect(parsed_url['restricted']).to be_nil
      end
    end

    context 'MARC 943 where url:href is not replaced (BOOKS)' do
      it 'does not set href value to soa_url for e-resources that are not JOURNAL or NEWSPAPER' do
        parsed_url = JSON.parse(url_943_non_journal_case['url'][0])
        expect(parsed_url['href']).not_to include(soa_url)
      end

      it 'does not change the URL href correctly when original URL include \'na05-psb\'' do
        rec = make_rec
        rec << MARC::DataField.new('943', '0', ' ',
                                  ['d', 'https://na05-psb.alma.exlibrisgroup.com/view/uresolver/01DUKE_INST/openurl?u.ignore_date_coverage=true&amp;portfolio_pid=53896265270008501&amp;Force_direct=true'],
                                  ['q', 'BOOK'],
                                  ['8', '53896265270008501']
                                  )
        result = run_traject_on_record('duke', rec)
        parsed_url = JSON.parse(result['url'][0])
        expect(parsed_url['href']).not_to match("#{soa_url}#{parsed_url['portfolio_id']}")
      end

      it 'does not set \'restricted: false\' for e-resources that are not JOURNAL or NEWSPAPER' do
        expect(JSON.parse(url_943_non_journal_case['url'][0])['restricted']).to be_nil
      end
    end

    context 'DUKE-BMCK-13-intelligize' do
      it 'does not set \'restricted: false\' when the URL includes \'apps.intelligize.com\'' do
        rec = make_rec
        rec << MARC::DataField.new('856', '4', '0',
                                  ['y', 'Law School users click here to access Intelligize'],
                                  ['u', 'apps.intelligize.com']
                                  )
        result = run_traject_on_record('duke', rec)
        expect(JSON.parse(result['url'][0])['restricted']).to be_nil
      end
    end

    context '944 fields:' do
      it 'correctly detects a MARC 944 field and sets the URL correctly' do
        rec = make_rec
        rec << MARC::DataField.new('944', '0', ' ',
                                  ['b', '61903212100008501']
                                  )
        result = run_traject_on_record('duke', rec)
        expect(JSON.parse(result['url'][0])['href']).to start_with(soa_url).and end_with('61903212100008501')
      end
    end
  end
end
