require 'spec_helper'

describe MarcToArgot::Macros::Duke::SharedRecords do
  include described_class

  let(:oupe) { run_traject_json('duke', 'oupe', 'xml') }

  context 'Duke' do
    it 'sets the virtual_collection' do
      expect(oupe['virtual_collection']).to(
        include('TRLN Shared Records. Oxford University Press online titles.')
      )
    end

    it 'sets institution to all that have access' do
      expect(oupe['institution']).to(
        eq(%w[duke unc ncsu nccu])
      )
    end

    it 'adds Shared Records to record_data_source' do
      expect(oupe['record_data_source']).to(
        include('Shared Records')
      )
    end

    it 'adds OUPE to record_data_source' do
      expect(oupe['record_data_source']).to(
        include('OUPE')
      )
    end

    it 'removes the Duke proxy if present' do
      expect(oupe['url']).to(
        eq(['{"href":"{+proxyPrefix}http://dx.doi.org/10.5743/cairo/9789774161032.001.0001","type":"fulltext"}'])
      )
    end

    it 'does not include a location_hierarchy' do
      expect(oupe.fetch('location_hierarchy', nil)).to be_nil
    end
  end
end
