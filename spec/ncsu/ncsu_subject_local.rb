require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:subjects_local_y) { run_traject_json('ncsu', 'subjects_local_y') }

  let(:subjects_local_v) { run_traject_json('ncsu', 'subjects_local_v') }

  let(:expected_values_y) do
    'Photography, Japanese -- 20th-21st century'
  end

  let(:expected_values_v) do
    'North Carolina State University -- Theses -- Applied Mathematics'
  end

  it 'extracts 690$y correctly' do
    headings = subjects_local_y['subject_headings'].map { |h| h['value'] }
    expect(headings).to include(expected_values_y)
  end

  it 'extracts 690$v correctly' do
    headings = subjects_local_v['subject_headings'].map { |h| h['value'] }
    expect(headings).to include(expected_values_v)
  end
end
