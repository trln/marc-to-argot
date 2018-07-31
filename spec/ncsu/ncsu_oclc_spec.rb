describe MarcToArgot do
  include Util::TrajectRunTest
  let(:empty_001) { run_traject_json('ncsu', 'oclc003-empty-001') }

  it 'fails to set an OCLC number when 001 is blank and 003=OCoLC' do
    expect(empty_001['oclc_number']).to be_nil
  end

  it 'fails to generate a rollup id when oclc number is not present' do
    expect(empty_001['rollup_id']).to be_nil
  end
end
