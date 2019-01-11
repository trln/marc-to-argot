describe MarcToArgot::Macros::NCSU::ISSNS do
  let(:ejournal_record) { run_traject_json('ncsu', 'ejournal') }

  it 'correctly extracts non-qualified issns from 022$a' do
    expect(ejournal_record['issn']).to eq('primary' => ['2326-067X'])
  end
end
