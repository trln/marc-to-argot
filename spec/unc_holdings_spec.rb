require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:b1246383argot) { run_traject_json('unc', 'b1246383') }

    it '(UNC) sets holdings locations' do
    expect(b1246383argot['holdings'][0]).to(
        include("\"loc_b\":\"trln\",\"loc_n\":\"trln\"")
    )
    end

    it '(UNC) sets holdings_id if checkout card count > 0' do
    expect(b1246383argot['holdings'][0]).to(
        include("\"holdings_id\":\"c1287725\"")
    )
    end

    it '(UNC) does NOT set holdings_id if checkout card count == 0' do
    expect(b1246383argot['holdings'][1]).not_to(
        include("\"holdings_id\":\"c1111111\"")
    )
    end

    it '(UNC) sets call number from 852, iii=c' do
    expect(b1246383argot['holdings'][0]).to(
        include("\"call_no\":\"HC102 .D8\"")
    )
    end

    it '(UNC) sets call number from MULTIPLE 852, iii=c' do
    expect(b1246383argot['holdings'][1]).to(
        include("\"call_no\":\"XC102 .D8; DQ102 .D8\"")
    )
    end

    it '(UNC) does NOT set call number from 852 when iii!=c' do
    expect(b1246383argot['holdings'][2]).not_to(
        include("\"call_no\":")
    )
    end

    it '(UNC) sets notes from 852 when iii=c' do
    expect(b1246383argot['holdings'][1]).to(
      include("\"notes\":[\"Test note 1\"]")
    )
    end

    it '(UNC) sets notes from 866, 867, 868' do
    expect(b1246383argot['holdings'][3]).to(
      include("\"notes\":[\"N1\",\"N2\",\"N4\",\"N3\"]")
    )
    end

    it '(UNC) sets summary holdings from 866' do
    expect(b1246383argot['holdings'][0]).to(
      include("\"summary\":\"1979:v.1, 1980 - 1987:A-F, 1987:P-2011\"")
    )
    end

    it '(UNC) sets supplementary content summary holdings from 867' do
    expect(b1246383argot['holdings'][1]).to(
      include("\"summary\":\"Supplementary holdings: 1970/1977 retrospective volume\"")
    )
    end

    it '(UNC) sets index content summary holdings from 868' do
    expect(b1246383argot['holdings'][2]).to(
      include("\"summary\":\"Index holdings: v.1/32(1895/1928) Name Index\"")
    )
    end

    it '(UNC) sets multi summary holdings from 866, 867, 868' do
    expect(b1246383argot['holdings'][3]).to(
      include("\"summary\":\"H1, H2; H3; Supplementary holdings: SH; Index holdings: IH\"")
    )
    end
end
