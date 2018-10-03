# coding: utf-8
describe MarcToArgot do
  include Util::TrajectRunTest

  describe "publisher" do
    let(:indexer) { load_indexer('unc', 'xml') }
    let(:records) { MARC::XMLReader.new(find_marc('unc', 'imprint')).to_a }
    let(:publisher_expectation) {
      [
        ['Writers and Readers Pub. Cooperative Society', 'Distributed in the U.S.A. by W.W. Norton'],
        ['Published by the editors in cooperation with the School of Liberal Arts at North Carolina State of the University of North Carolina', 'English Dept., UNCC', 'Advancment Studies, CPCC', 'English Dept., CPCC', 'Dept. of Languages, Literature & Philosophy, Armstrong Atlantic State University'],
        ['Dodd, Mead', 'Beacon Press', 'Chilton Book Co.', 'Applause Theater Book Publishers'],
        ['Channel Four (Great Britain)', 'Films Media Group'],
        ['Douglass College, Rutgers University', 'Transaction Publishers'],
        ['"N. Niva, "', 'O.D. Strokʺ', 'publisher not identified', '"Н. Нива, "', 'О.Д. Строкъ'],
        ['William S. Hein & Co.', 'William S. Hein & Company']
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

    xit '(MTA) sets publisher from 260 and linked 880' do
      result = imprint_v1['publisher']
      expect(result).to eq(
                          [
                            {'value': 'In-t vseobshcheĭ istorii RAN'},
                            {'value': 'Nauka'},
                            {'value': 'Ин-т всеобщей истории РАН', 'lang': 'rus'},
                            {'value': 'Наука', 'lang': 'rus'} 
                          ]
                        )
    end

  end
end
