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
      index = idx + 1
      expect(output.length).to eq(exp.length), "Record #{index} in error, output #{output}, expected #{exp}" unless exp.nil?
      expect(output['rollup_id']).to eq(exp)
    end
  end

  it 'sets primary_oclc 035$q does not contain the string ‘exclude’' do
    result = run_traject_json('ncsu', 'archival_material', 'xml')
    expect(result['primary_oclc']).to eq(['566307606'])
  end  

  it 'sets primary_oclc to nil when 035$q contains the string ‘exclude’' do
    result = run_traject_json('ncsu', 'primary_oclc_exclude', 'xml')
    expect(result['primary_oclc']).to be_nil
  end
end
