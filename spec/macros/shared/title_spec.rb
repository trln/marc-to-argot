describe MarcToArgot::Macros::Shared::Title do
  include described_class

  context '#short_title' do
    let(:macro) { short_title }
    let(:short_title_context) do
      ctx = Traject::Indexer::Context.new
      ctx.output_hash['title_main'] = [{ value: 'A Short Title.' }]
      ctx
    end

    let(:long_title_context) do
      ctx = Traject::Indexer::Context.new
      ctx.output_hash['title_main'] = [{ value: 'Not Really a Short Title at All.' }]
      ctx
    end

    it 'extracts a short title when output hash is populated' do
      acc = []
      macro.call([], acc, short_title_context)
      expect(acc.first).to eq('A Short Title')
    end

    it 'does not extract a short title when title_main is too long' do
      acc = []
      macro.call([], acc, long_title_context)
      expect(acc).to be_empty
    end

    it 'does not error out when title_main is not populated' do
      ctx = Traject::Indexer::Context.new
      acc = []
      macro.call([], acc, ctx)
      expect(acc).to be_empty
    end
  end
end
