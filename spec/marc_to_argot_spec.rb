require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  it 'has a version number' do
    expect(MarcToArgot::VERSION).not_to be nil
  end

  it 'generates base results for NCSU' do
    result = run_traject('ncsu', 'base')
    expect(result).not_to be_empty
  end

  it 'generates base results for Duke' do
    result = run_traject('duke', 'base', 'mrc')
    expect(result).not_to be_empty
  end

  it 'generates author facet value if relators include punctuation' do
    b1082803argot = run_traject_json('unc', 'b1082803')
    expect(b1082803argot['author_facet']).to(
      include('Gregory, Lady, 1852-1932')
    )
  end

  it 'does NOT generate a rollup_id for Duke special collections records' do
    result = run_traject_json('duke', 'special_collections', 'mrc')
    expect(result['rollup_id']).to(be_nil)
  end

  it 'generates base results for UNC' do
    result = run_traject('unc', 'base')
    expect(result).not_to be_empty
  end

  it 'generates record_data_source value for UNC' do
    b1082803argot = run_traject_json('unc', 'b1082803')
    expect(b1082803argot['record_data_source']).to(
      eq(['ILSMARC'])
    )
  end

  it 'generates record_data_source value for Duke' do
    result = run_traject_json('duke', 'rollup_id', 'mrc')
    expect(result['record_data_source']).to(
      eq(['ILSMARC'])
    )
  end
end
