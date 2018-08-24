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
      context 'At least one 863 with III field type = h AND' do
        context 'There is a single level of enumeration AND' do
          context 'Year-only chronology AND' do 
            context 'The open and close year is the same year' do

            # y 853  30|81|av.|i(year)|tc.
            # h 863    |81.1|a1-3|i1939
            it '(UNC) provides summary holdings statement' do
              expect(holdings1['holdings'][0]).to(
                include("\"summary\":\"v. 1 (1939) - v. 3 (1939)")
              )
            end

            context 'AND year is incomplete' do
              # 853  30|81|av.|i(year)
              # 863  30|81.1|a5-6|i1971-1972|wg
              # 863  31|81.2|a7|i1973|zincomplete
              # 863  40|81.3|a8-10|i1974-1976
              it '(UNC) provides summary holdings statement' do
                expect(holdings4['holdings'][0]).to(
                  include("\"summary\":\"v. 5 (1971) - v. 6 (1972), v. 7 (1973) incomplete, v. 8 (1974) - v. 10 (1976)")
                )
              end
            end

            context 'AND close of range is TO DATE' do
              # y 853  |81|av.|i(year)
              # h 863  |81.1|a1-|i1921-|pHAHE-5109-00001|zTO DATE

              it '(UNC) provides summary holdings statement' do
                expect(holdings5['holdings'][0]).to(
                  include("\"summary\":\"v. 1 (1921) TO DATE\"")
                )
              end                        
            end
          end
            
          context 'The open and close year are different' do
            # y	853  30|81|av.|bno.|i(year)|j(month)
            # h	863  40|81.1|a1-4|i1971-1974
            it '(UNC) provides summary holdings statement' do
              expect(holdings2['holdings'][0]).to(
                include("\"summary\":\"v. 1 (1971) - v. 4 (1974)")
              )
            end
          end
          end
        end

        context 'There are 2 levels of enumeration AND' do
          context 'A month/year chronology AND' do
            context 'There are 2 different patterns' do

              # y	853  30|81|aBd.|bHeft |i(year)|j(month)
              # y	853  31|82|aJahrg.|bHeft |i(year)
              # h	863  40|81.1|a1-32|b1-3|i1928-1933|jJan.-Juni|wn
              # h	863  40|82.2|a19-38|b1-2|i1961-1980
            it '(UNC) provides summary holdings statement' do
              expect(holdings3['holdings'][0]).to(
                include("\"summary\":\"Bd. 1:Heft 1 (Jan. 1928) - Bd. 32:Heft 3 (Juni 1933); Jahrg. 19:Heft 1 (1961) - Jahrg. 38:Heft 2 (1980)")
              )
            end

            end
          end
        end
      end
    end
  end
end

