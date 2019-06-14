# coding: utf-8
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

  context 'short title in 245 and linked 880 present' do
      xit '(MTA) sets short_title from both?' do
        rec = make_rec
        rec << MARC::DataField.new('245', '0', '1',
                                   ['6', '880-01'],
                                   ['a', 'Ubileĭnoe izd'])
        rec << MARC::DataField.new('880', '0', '1',
                                   ['6', '245-01'],
                                   ['a', 'Юбилейное изд'])
        result = run_traject_on_record('unc', rec)['short_title']
        expect(result).to eq(
                            [ 'Ubileĭnoe izd', 'Юбилейное изд' ]
                          )
      end
  end

  context 'non-Roman short title in 245' do
    xit '(MTA) sets non-Roman short title' do
      rec = make_rec
      rec << MARC::DataField.new('245', '1', '0',
                                 ['a', 'Юбилейное изд'])
      result = run_traject_on_record('unc', rec)['short_title']
      expect(result).to eq(
                          [ 'Юбилейное изд' ]
                        )
    end
  end

end
