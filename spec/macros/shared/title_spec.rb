# coding: utf-8
describe MarcToArgot::Macros::Shared::Title do
  include described_class

  context '#short_title' do
    it 'extracts a short title' do
      rec = make_rec
      rec << MARC::DataField.new('245', '0', '0', ['a', 'A Short Title.'], ['b', 'Subtitle'], ['z', '9789575433741'])
      result = run_traject_on_record('ncsu', rec)
      expect(result['short_title'].first).to eq('A Short Title')
    end

    it 'does not extract a short title when short_title is too long' do
      rec = make_rec
      rec << MARC::DataField.new('245', '0', '0', ['a', 'Not Really a Short Title at All.'], ['z', '9789575433741'])
      result = run_traject_on_record('ncsu', rec)
      expect(result['short_title']).to be_nil
    end

    it 'does not error out when short_title is not populated' do
      rec = make_rec
      rec << MARC::DataField.new('245', '0', '0', ['z', '9789575433741'])
      result = run_traject_on_record('ncsu', rec)
      expect(result['short_title']).to be_nil
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
