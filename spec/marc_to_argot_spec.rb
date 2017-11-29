require 'spec_helper'

describe MarcToArgot do
  it 'has a version number' do
    expect(MarcToArgot::VERSION).not_to be nil
  end

  it 'loads base spec successfully' do
    spec = MarcToArgot::SpecGenerator.new('argot')
    result = spec.generate_spec
    expect(result).to be_kind_of(Hash)
    expect(result).not_to be_empty
    expect(result['id']).to eq('001')
  end

  it 'loads NCSU spec without a problem' do
    spec = MarcToArgot::SpecGenerator.new('ncsu')
    result = spec.generate_spec
    expect(result['id']).to eq('918a')
  end

  it 'generates base results for NCSU' do
    result = Util::TrajectRunTest.run_traject('ncsu', 'base')
    expect(result).not_to be_empty
  end

  it 'loads Duke spec without a problem' do
    spec = MarcToArgot::SpecGenerator.new('duke')
    result = spec.generate_spec
    expect(result['id']).to eq('001')
  end

  it 'generates base results for Duke' do
    result = Util::TrajectRunTest.run_traject('duke', 'base', 'mrc')
    expect(result).not_to be_empty
  end

  it 'generates author facet value if relators include punctuation' do
    b1082803argot = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'b1082803') )
    expect(b1082803argot['author_facet']).to(
      include('Gregory, Lady, 1852-1932')
    )
  end

  it 'loads UNC spec without a problem' do
    spec = MarcToArgot::SpecGenerator.new('unc')
    result = spec.generate_spec
    expect(result['id']).to eq('907a')
  end

  it 'generates base results for UNC' do
    result = Util::TrajectRunTest.run_traject('unc', 'base')
    expect(result).not_to be_empty
  end

  it 'generates record_data_source value for UNC' do
    b1082803argot = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'b1082803') )
    expect(b1082803argot['record_data_source']).to(
      eq(['ILSMARC'])
    )
  end

  it 'generates record_data_source value for Duke' do
    result = JSON.parse( Util::TrajectRunTest.run_traject('duke', 'rollup_id', 'mrc') )
    expect(result['record_data_source']).to(
      eq(['ILSMARC'])
    )
  end

end
