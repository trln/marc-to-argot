# coding: utf-8
describe MarcToArgot do
  include Util::TrajectRunTest

  describe "publisher" do
    let(:indexer) { load_indexer('unc', 'xml') }
    let(:records) { MARC::XMLReader.new(find_marc('unc', 'imprint')).to_a }
    let(:publisher_expectation) {
      [
        [{ 'value' => 'Writers and Readers Pub. Cooperative Society' },
         { 'value' => 'Distributed in the U.S.A. by W.W. Norton' }],
        [{ 'value' => 'Published by the editors in cooperation with the School of Liberal Arts '\
                      'at North Carolina State of the University of North Carolina' },
         { 'value' => 'English Dept., UNCC' },
         { 'value' => 'Advancment Studies, CPCC' },
         { 'value' => 'English Dept., CPCC' },
         { 'value' => 'Dept. of Languages, Literature & Philosophy, Armstrong Atlantic State University' }],
        [{ 'value' => 'Dodd, Mead' },
         { 'value' => 'Beacon Press' }, {'value'=> 'Chilton Book Co.' },
         { 'value' => 'Applause Theater Book Publishers' }],
        [{ 'value' => 'Channel Four (Great Britain)' },
         { 'value' => 'Films Media Group' }],
        [{ 'value' => 'Douglass College, Rutgers University' },
         { 'value' => 'Transaction Publishers' }],
        [{ 'value' => '"N. Niva, "' },
         { 'value' => 'O.D. Strokʺ' },
         { 'value' => 'publisher not identified' },
         { 'value' => '"Н. Нива, "', 'lang'=> 'rus' },
         { 'value' =>  'О.Д. Строкъ', 'lang'=> 'rus' }],
        [{ 'value' => 'William S. Hein & Co.' },
         { 'value' => 'William S. Hein & Company' }]
      ]
    }

    it 'extracts publisher' do
      records.each_with_index do |rec, idx|
        output = indexer.map_record(rec)
        exp = publisher_expectation[idx]
        expect(output['publisher'].length).to eq(exp.length) unless exp.nil?
        expect(output['publisher']).to eq(exp.nil? ? nil : exp)
      end
    end

    let(:imprint_v1) { run_traject_json('unc', 'imprint_v1', 'mrc') }

    it '(MTA) sets publisher from 260 and linked 880' do
      result = imprint_v1['publisher']
      expect(result).to eq(
                          [
                            { 'value' => 'In-t vseobshcheĭ istorii RAN' },
                            { 'value' => 'Nauka' },
                            { 'value' => 'Ин-т всеобщей истории РАН', 'lang'=> 'rus' },
                            { 'value' => 'Наука', 'lang'=> 'rus' }
                          ]
                        )
    end

  end
end
