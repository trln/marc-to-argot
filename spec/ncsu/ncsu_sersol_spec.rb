describe MarcToArgot do
  include Util::TrajectRunTest
  let(:oclc) { run_traject_json('ncsu', 'ejournal') }
  let(:no_oclc) { run_traject_json('ncsu', 'no-oclc-ejournal') }

  it 'sets oclc as rollup id if present' do
    expect(oclc['rollup_id']).to(
      eq('OCLC58839179')
    )
  end

  it 'sets sersol_number if present in the 035a' do
    expect(oclc['sersol_number']).to(
      eq(['ssj0037072'])
    )
  end

  it 'sets serials solution id as rollup id if no oclc id' do
    expect(no_oclc['rollup_id']).to(
      eq('ssj0037072')
    )
  end
end