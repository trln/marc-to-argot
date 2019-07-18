describe MarcToArgot::Macros::NCSU do

	# record has a 710 where $3 != 'Donor'
	let(:no_donor) { run_traject_json('ncsu', 'no_donor') }

	# record has two 710s, one where $3 = 'Donor'
	# and one does not
  	let(:donor) { run_traject_json('ncsu', 'donor') }

	context '#donor' do
  		it 'correctly extracts donor names' do
    		expect(donor['donor'].length).to eq(1)
    		expect(donor['donor'].first).to eq("Donor Donorson Foundation")
  		end

  		it 'does not extract donor names from other 710' do
  			expect(no_donor['donor']).to be_nil
  		end
  	end
end
