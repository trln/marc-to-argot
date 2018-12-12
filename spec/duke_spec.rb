require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest

  it '(Duke) generates oclc_number' do
    result = run_traject_json('duke', 'rollup_id', 'mrc')
    expect(result['oclc_number']).to(
      eq({ "value" => '12420922'})
    )
  end

  it '(Duke) generates rollup_id' do
    result = run_traject_json('duke', 'rollup_id', 'mrc')
    expect(result['rollup_id']).to(
      eq('OCLC12420922')
    )
  end

  it '(Duke) generates rollup_id from sersol number' do
    result = run_traject_json('duke', 'sersol_rollup', 'xml')
    expect(result['rollup_id']).to(
      eq('ssib031808849')
    )
  end

  it '(Duke) does NOT generate a rollup_id for Duke special collections records' do
    result = run_traject_json('duke', 'special_collections', 'mrc')
    expect(result['rollup_id']).to(be_nil)
  end

  it '(Duke) generates date_cataloged from valid date string' do
    result = run_traject_json('duke', 'date_cataloged_valid', 'mrc')
    expect(result['date_cataloged'].first).to(match(/^2012-09-04.*/))
  end

  it '(Duke) survives an invalid date string and does not set a value for date_cataloged' do
    result = run_traject_json('duke', 'date_cataloged_invalid', 'mrc')
    expect(result['date_cataloged']).to(be_nil)
  end

  it '(Duke) adds a "DUKE" prefix to the record id if it is missing.' do
    result = run_traject_json('duke', 'non_prefixed_id', 'mrc')
    expect(result['id']).to eq('DUKE002959320')
  end

  it '(Duke) does NOT add a "DUKE" prefix to the record id if it is present.' do
    result = run_traject_json('duke', 'prefixed_id', 'mrc')
    expect(result['id']).to eq('DUKE002959320')
  end
end
