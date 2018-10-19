describe MarcToArgot do

  let(:short_title_science) { run_traject_json('ncsu', 'short_title_science') }
  let(:short_title_jpp) { run_traject_json('ncsu', 'jpsychphysio') }
  let(:long_title) { run_traject_json('ncsu', 'long_title') }

  it 'populates short_title for "Science." properly from MARC' do
    expect(short_title_science['short_title'].first).to eq("Science")
  end

  it 'populates short_title for a three-word title' do
    expect(short_title_jpp['short_title'].first).to eq('Journal of psychophysiology')
  end

  it 'does not populate short_title for a long title' do
    expect(long_title).not_to have_key('short_title')
  end
end
