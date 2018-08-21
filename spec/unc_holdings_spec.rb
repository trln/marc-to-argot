require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:b1246383argot) { run_traject_json('unc', 'b1246383') }
  let(:holdings1) { run_traject_json('unc', 'holdings1') }
  let(:holdings2) { run_traject_json('unc', 'holdings2') }
  let(:holdings3) { run_traject_json('unc', 'holdings3') }
  let(:holdings4) { run_traject_json('unc', 'holdings4') }
  let(:holdings5) { run_traject_json('unc', 'holdings5') }
  let(:holdings6) { run_traject_json('unc', 'holdings6') }

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

    context 'When textual holdings field(s) with III field type = h are present' do
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

    context 'When textual holdings field(s) with III field type = h are NOT present AND' do
      context 'There is at least one 853 with III field type = y AND' do
        context 'There is at least one 863 with III field type = h' do

          # y 853  30|81|av.|i(year)|tc.
          # h 863    |81.1|a1-3|i1939
          # should produce
          #  v.1 (1939) - v.3 (1939)
          
          it '(UNC) provides summary holdings statement' do
            expect(holdings1['holdings'][0]).to(
              include("\"summary\":\"v.1 (1939) - v.3 (1939)")
            )
          end

          # 2 v.1 (1971) - v.4 (1974) -- ACCEPT: v. 1-4 (1971-1974)
          # 3 Bd.1:Heft 1 (Jan. 1928) - Bd.32:Heft 3 (Juni 1933); Jahrg.19:Heft 1 (1961) - Jahrg.38:Heft 2 (1980)
          # 4 v.5 (1971) - v.6 (1972), v.7 (1973) incomplete, v.8 (1974) - v.10 (1976)
          # 5 v.1 (1921)- TO DATE (Davis Library Federal Documents) --- v.60:no.1 (Jan. 1980) - v.72:no.6 (June 1992) (LSC)
          # 6 v.9 (1943) - v.15 (1949), v.22 (1956) - v.23 (1957), v.27 (1961), v.29 (1963), v.32 (1966) - v.33 (1967), v.36 (1970) - v.42 (1976)

        end
      end
    end
end
