require 'spec_helper'
require 'marc_to_argot'

describe MarcToArgot do
b1246383argot = JSON.parse( TrajectRunTest.run_traject('unc', 'b1246383') )

    it 'sets holdings locations' do
    expect(b1246383argot['holdings'][0]).to(
        include("\"loc_b\":\"trln\",\"loc_n\":\"trln\"")
    )
    end

end