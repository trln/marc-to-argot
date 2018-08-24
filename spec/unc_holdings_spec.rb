# coding: iso-8859-1
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

=begin
holdings6 - c4900227 - b6820876
y	853  |81|aa�o |bMes |cno.|i(year)|j(month)|k(day)
h	863  30|81.1|a56-57|b8-1|c16.512-16.644|i1928|jmayo-oct.|k22-27|zSome issues missing
a�o 56:Mes 8:no.16.512 (mayo 22, 1928) - a�o 57:Mes 1:no.16.644 (oct. 27, 1928) Some issues missing


holdings7 - c4671488 - b4945723
y	853  |81|av.|bno.|i(year)|j(month)|k(day)
y	853  |82|a(year)|b(month)|c(day)
h	863  41|81.1|a1|b11|i1959|j04|k1
h	863  41|81.2|a1|b23|i1959|j06|k29
h	863  40|81.3|a1|b27-33|i1959|j07-09|k27-7
h	863  41|81.4|a1|b36|i1959|j09|k28
h	863  40|81.5|a1|b44-49|i1959|j11-12|k23-28
h	863  40|81.6|a2|b1-4|i1960|j01|k4-25
h	863  41|81.7|a2|b13|i1960|j03|k28
h	863  41|81.8|a2|b39|i1960|j09|k26
h	863  41|81.9|a2|b52|i1960|j12|k26
h	863  41|82.10|a1961|b03|c27
h	863  41|82.11|a1961|b06|c26
h	863  41|82.12|a1961|b09|c25
h	863  41|82.13|a1961|b12|c25
h	863  41|82.14|a1962|b03|c26
h	863  41|82.15|a1962|b12|c31
h	863  41|82.16|a1963|b04|c1
h	863  41|82.17|a1963|b07|c1
h	863  41|82.18|a1963|b09|c30
h	863  41|82.19|a1963|b12|c30
h	863  40|82.20|a1964-1965|b02-10|c24-11
h	863  40|82.21|a1965-1966|b12-1|c27-24
h	863  41|82.22|a1966|b03|c28
h	863  41|82.23|a1966|b06|c27
h	863  41|82.24|a1966|b09|c26
h	863  41|82.25|a1966|b12|c26
h	863  41|82.26|a1967|b03|c27
h	863  41|82.27|a1967|b06|c26
h	863  41|82.28|a1967|b09|c25
h	863  41|82.29|a1967|b12|c25
h	863  41|82.30|a1968|b02|c26
h	863  41|82.31|a1968|b03|c25
h	863  41|82.32|a1968|b06|c24
h	863  41|82.33|a1968|b09|c30
h	863  41|82.34|a1968|b12|c30
h	863  41|82.35|a1969|b03|c31
h	863  41|82.36|a1969|b06|c30
h	863  41|82.37|a1969|b09|c29
h	863  41|82.38|a1969|b12|c29
h	863  41|82.39|a1971|b12|c27
h	863  41|82.40|a1972|b03|c27
h	863  41|82.41|a1972|b06|c26
h	863  41|82.42|a1972|b09|c25
h	863  41|82.43|a1972|b12|c25
h	863  41|82.44|a1973|b03|c26
h	863  41|82.45|a1973|b06|c25
h	863  41|82.46|a1973|b09|c24
h	863  41|82.47|a1973|b12|c31
h	863  40|82.48|a1974|b01-06|c7-24
h	863  40|82.49|a1974|b07-09|c15-23
h	863  40|82.50|a1974|b10-12|c14-23
h	863  41|82.51|a1975|b01|c6
h	863  40|82.52|a1975|b01-02|c20-10
v. 1:no. 11 (Apr. 1, 1959), v. 1:no. 23 (June 29, 1959), v. 1:no. 27 (July 27, 1959) - v. 1:no. 33 (Sept. 7, 1959), v. 1:no. 36 (Sept. 28, 1959), v. 1:no. 44 (Nov.  23, 1959) - v. 1:no. 49 (Dec. 28, 1959), v. 2:no. 1 (Jan. 4, 1960) - v. 2:no. 4 (Jan. 25, 1960), v. 2:no. 13 (Mar. 28, 1960), v. 2:no. 39 (Sept. 26, 1960), v. 2:no. 52 (Dec. 26, 1960), Mar. 27, 1961, June 26, 1961, Sept. 25, 1961, Dec. 25, 1961, Mar. 26, 1962, Dec. 31, 1962, Apr. 1, 1963, July 1, 1963, Sept. 30, 1963, Dec. 30, 1963, Feb. 24, 1964 - Oct. 11, 1965, Dec. 27, 1965 - Jan. 24, 1966, Mar. 28, 1966, June 27, 1966, Sept. 26, 1966, Dec. 26, 1966, Mar. 27, 1967, June 26, 1967, Sept. 25, 1967, Dec. 25, 1967, Feb. 26, 1968, Mar. 25, 1968, June 24, 1968, Sept. 30, 1968, Dec. 30, 1968, Mar. 31, 1969, June 30, 1969, Sept. 29, 1969, Dec. 29, 1969, Dec. 27, 1971, Mar. 27, 1972, June 26, 1972, Sept. 25, 1972, Dec. 25, 1972, Mar. 26, 1973, June 25, 1973, Sept. 24, 1973, Dec. 31, 1973, Jan. 7, 1974 - June 24, 1974, July 15, 1974 - Sept. 23, 1974, Oct. 14, 1974 - Dec. 23, 1974, Jan. 6, 1975, Jan. 20, 1975 - Feb. 10, 1975

holdings8 - c1346919 - b1300565
y	853  30|81|av.|bpt.|ct.
h	863  40|81.1|a1|wg
h	863  41|81.2|a4|b2|c1
v. 1, v. 4:pt. 2:t. 1 

holdings9 - c1361861 - b1317354
y	853  30|81|av.|i(year)
h	863  40|81.9|a9-15|i1943-1949|wg
h	863  40|81.22|a22-23|i1956-1957|wg
h	863  41|81.27|a27|i1961|wg
h	863  41|81.29|a29|i1963|wg
h	863  40|81.32|a32-33|i1966-1967|wg
h	863  40|81.36|a36-42|i1970-1976
v. 9 (1943) - v. 15 (1949), v. 22 (1956) - v. 23 (1957), v. 27 (1961), v. 29 (1963), v. 32 (1966) - v. 33 (1967), v. 36 (1970) - v. 42 (1976)

holdings10 - c1503867 - b1514689
y	853  3|81|a�rg.|gnr.|i(year)
h	863  40|81.1|a8-17|g29-68|i1977-1990
�rg. 8 (1977) - �rg. 17 (1990) = nr. 29 - nr. 68

holdings11 - c1360005 - b1315368
y	853  3|81|aa�o |i(year)|gno.
y	855  |81|ano.|i(year)
h	863  30|81.1|a1|i1952|b1-8|zincomplete
h	863  40|81.2|a2-23|i1953-1974
h	865  41|81.3|a1-62|i1952-1961
Lib Has	a�o 1 (1952) - a�o 1 (1952) = - incomplete, a�o 2 (1953) - a�o 23 (1974) = -
INDEXES 	no.1 (1952) - no.62 (1961)


=end
