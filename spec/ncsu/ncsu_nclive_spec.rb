
describe MarcToArgot::Indexers::NCSU do

  let(:records) { load_json_multiple(run_traject('ncsu', 'nclive-records')) }

  it 'get unique id from each record' do

    records.each_with_index do |rec, idx|
	urls=rec["url"]
	datasource=rec["record_data_source"]
	expect(urls.length).to eq(1)	
	expect(JSON.parse(urls.first)["href"]).to start_with("{+proxyPrefix}")	
	expect(rec["record_data_source"]).to eq(["ILSMARC", "Shared Records", "NCLIVE"])
        expect(rec["virtual_collection"]). to eq(["TRLN Shared Records. NC LIVE videos."])
	expect(rec["institution"]).to include("ncsu", "unc", "duke", "nccu")
        expect(rec["access_type"]).to eq(["Online"])
    end
  end
end
