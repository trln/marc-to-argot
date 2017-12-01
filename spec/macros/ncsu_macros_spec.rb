describe MarcToArgot::Macros::NCSU do
  include Util

  let(:indexer) { MarcToArgot::Indexers::NCSU.new }
  let(:records) { MARC::XMLReader.new(find_marc('ncsu', 'base')).to_a }
  let(:expected_rollups) {
    [%w[OCLC521064822], %w[OCLC21338035], nil, %w[OCLC65355424], %w[OCLC30104535]]
  }

  it 'extracts a correct rollup id' do
    indexer.instance_eval do
      to_field 'rollup_id', rollup_id
    end
    records.each_with_index do |rec, idx|
      output = indexer.map_record(rec)
      exp = expected_rollups[idx]
      expect(output.length).to eq(exp.length), "Record #{idx +1} in error, output #{output}, expected #{exp}" unless exp.nil?
      expect(output['rollup_id']).to eq(exp)
    end
  end
end
