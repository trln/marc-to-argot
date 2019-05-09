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

  it 'does NOT generate a rollup_id for Duke special collections records' do
    result = run_traject_json('duke', 'special_collections', 'mrc')
    expect(result['rollup_id']).to(be_nil)
  end

  it 'joins frequency_current subfields together' do
    result = run_traject_json('duke', 'frequency', 'mrc')
    expect(result['frequency']['current']).to(
      include('Quarterly, 1971-winter 1972')
    )
  end

  it 'joins frequency_former subfields together' do
    result = run_traject_json('duke', 'frequency', 'mrc')
    expect(result['frequency']['former']).to(
      include('Monthly, 1965-1970')
    )
  end

  it 'generates base results for UNC' do
    result = run_traject('unc', 'base')
    expect(result).not_to be_empty
  end

  it 'generates record_data_source value for UNC' do
    rec = make_rec
    result = run_traject_on_record('unc', rec)['record_data_source']
    expect(result).to eq(['ILSMARC'])
  end

  it 'generates record_data_source value for Duke' do
    result = run_traject_json('duke', 'rollup_id', 'mrc')
    expect(result['record_data_source']).to(
      eq(['ILSMARC'])
    )
  end
end
