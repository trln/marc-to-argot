
describe MarcToArgot::Indexers::EEBO do
  include Util

  let(:indexer) { MarcToArgot::Indexers::EEBO.new }
  let(:records) { load_json_multiple(run_traject('eebo', 'sample_records')) }

  it 'extracts a unique id' do
    indexer.instance_eval do
      to_field 'id', extract_marc("001") 
    end
    records.each_with_index do |rec, idx|
	urls=rec["url"]
	datasource=rec["record_data_source"]
	expect(urls.length).to eq(1)	
	expect(JSON.parse(urls.first)["href"]).to start_with("{+proxyPrefix}")	
	expect(rec["id"]).to start_with("EEBO")
	expect(rec["record_data_source"]).to eq(["MARC", "Shared Records", "EEBO"])
        expect(rec["virtual_collection"]). to eq(["TRLN Shared Records. Early English Books Online."])
	expect(rec["institution"]).to eq(["ncsu", "unc", "duke"])
        expect(rec["access_type"]).to eq(["Online"])
    end
  end
end
