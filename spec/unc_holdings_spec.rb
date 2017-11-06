require 'spec_helper'
require 'marc_to_argot'

describe MarcToArgot do
b1246383argot = JSON.parse( TrajectRunTest.run_traject('unc', 'b1246383') )

    it 'sets holdings locations' do
    expect(b1246383argot['holdings'][0]).to(
        include("\"loc_b\":\"trln\",\"loc_n\":\"trln\"")
    )
    end

    it 'sets holdings_id if checkout card count > 0' do
    expect(b1246383argot['holdings'][0]).to(
        include("\"holdings_id\":\"c1287725\"")
    )
    end

    it 'does NOT set holdings_id if checkout card count == 0' do
    expect(b1246383argot['holdings'][1]).not_to(
        include("\"holdings_id\":\"c1111111\"")
    )
    end

    it 'sets call number from 852, iii=c' do
    expect(b1246383argot['holdings'][0]).to(
        include("\"call_no\":\"HC102 .D8\"")
    )
    end

    it 'sets call number from MULTIPLE 852, iii=c' do
    expect(b1246383argot['holdings'][1]).to(
        include("\"call_no\":\"XC102 .D8; DQ102 .D8\"")
    )
    end
end
