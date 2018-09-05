# coding: utf-8
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
  let(:holdings7) { run_traject_json('unc', 'holdings7') }
  let(:holdings8) { run_traject_json('unc', 'holdings8') }
  let(:holdings9) { run_traject_json('unc', 'holdings9') }
  let(:holdings10) { run_traject_json('unc', 'holdings10') }
  let(:holdings11) { run_traject_json('unc', 'holdings11') }
  let(:holdings12) { run_traject_json('unc', 'holdings12') }
  let(:holdings13) { run_traject_json('unc', 'holdings13') } 
  let(:holdings14) { run_traject_json('unc', 'holdings14') }
  let(:holdings15) { run_traject_json('unc', 'holdings15') }
  let(:holdings16) { run_traject_json('unc', 'holdings16') }
  let(:holdings17) { run_traject_json('unc', 'holdings17') }
  
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

    it '(UNC) sets call number' do
      expect(holdings12['holdings'][0]).to(
        include("\"call_no\":\"E65 .S45a v.2, etc.\"")
      )
    end

    it '(UNC) sets summary' do
      expect(holdings12['holdings'][0]).to(
        include("\"summary\":\"v.2 = t.1, v.4 = t.2, v.6 = t.3, v.8 = t.4, v.10 = t.5\"")
      )
    end

        it '(UNC) sets summary' do
      expect(holdings13['holdings'][0]).to(
        include("\"summary\":\"v.8:no.2 (Autumn 1982) - v.16:no.2 (Autumn 1990) = issue 16 - issue 32")
      )
    end


end

  context 'When 866 with III field type = h are NOT present AND' do
    context 'There is at least one 853 with III field type = y AND' do
      context 'At least one 863 with III field type = h AND' do
        context 'There is a single level of enumeration AND' do
          context 'Year-only chronology AND' do
            
            context 'The open and close year is the same year' do
              # y 853  30|81|av.|i(year)|tc.
              # h 863    |81.1|a1-3|i1939
              it '(UNC) provides summary holdings statement' do
                expect(holdings1['holdings'][0]).to(
                  include("\"summary\":\"v.1 (1939) - v.3 (1939)")
                )
              end
            end

            context 'AND year is incomplete, noted in $z' do
              # 853  30|81|av.|i(year)
              # 863  30|81.1|a5-6|i1971-1972|wg
              # 863  31|81.2|a7|i1973|zincomplete
              # 863  40|81.3|a8-10|i1974-1976
              it '(UNC) provides summary holdings statement' do
                expect(holdings4['holdings'][0]).to(
                  include("\"summary\":\"v.5 (1971) - v.6 (1972), v.7 (1973) incomplete, v.8 (1974) - v.10 (1976)")
                )
              end
            end

            context 'AND close of range is TO DATE, noted in $z' do
              # y 853  |81|av.|i(year)
              # h 863  |81.1|a1-|i1921-|pHAHE-5109-00001|zTO DATE

              it '(UNC) provides summary holdings statement' do
                expect(holdings5['holdings'][0]).to(
                  include("\"summary\":\"v.1 (1921) TO DATE\"")
                )
              end                        
            end

            context 'Some 863s are complete but not ranges' do
              # y	853  30|81|av.|i(year)
              # h	863  40|81.9|a9-15|i1943-1949|wg
              # h	863  40|81.22|a22-23|i1956-1957|wg
              # h	863  41|81.27|a27|i1961|wg
              # h	863  41|81.29|a29|i1963|wg
              # h	863  40|81.32|a32-33|i1966-1967|wg
              # h	863  40|81.36|a36-42|i1970-1976
              it '(UNC) provides summary holdings statement' do
                expect(holdings9['holdings'][0]).to(
                  include("\"summary\":\"v.9 (1943) - v.15 (1949), v.22 (1956) - v.23 (1957), v.27 (1961), v.29 (1963), v.32 (1966) - v.33 (1967), v.36 (1970) - v.42 (1976)\"")
                )
              end
            end

            context 'AND there is a 1-level alt num scheme specified in 853' do
              # y	853  3|81|aÃ¥rg.|gnr.|i(year)
              # h	863  40|81.1|a8-17|g29-68|i1977-1990
              it '(UNC) provides summary holdings statement' do
                expect(holdings10['holdings'][0]).to(
                  include("\"summary\":\"årg.8 (1977) - årg.17 (1990) = nr.29 - nr.68\"")
                )
              end

              context 'BUT no alt numeration specified in 863s' do
                it '(UNC) provides summary holdings statement' do
                  # y	853  3|81|aaÃ±o |i(year)|gno.
                  # y	855  |81|ano.|i(year)
                  # h	863  30|81.1|a1|i1952|b1-8|zincomplete
                  # h	863  40|81.2|a2-23|i1953-1974
                  # h	865  41|81.3|a1-62|i1952-1961
                  expect(holdings11['holdings'][0]).to(
                    include("\"summary\":\"año 1 (1952) - año 1 (1952) incomplete, año 2 (1953) - año 23 (1974);")
                  )
                end
              end
            end
          end
        end

        context 'There are 2 levels of enumeration' do
          context 'AND A month/year chronology' do
            context 'BUT only year chronology recorded in 863' do
              context 'AND There is only one 1 enumeration level specified in 863' do
                context 'AND The open and close year are different' do
                  # y	853  30|81|av.|bno.|i(year)|j(month)
                  # h	863  40|81.1|a1-4|i1971-1974
                  it '(UNC) provides summary holdings statement' do
                    expect(holdings2['holdings'][0]).to(
                      include("\"summary\":\"v.1 (1971) - v.4 (1974)")
                    )
                  end
                end
              end
            end

            context 'AND there are 2 different patterns' do
              # y	853  30|81|aBd.|bHeft |i(year)|j(month)
              # y	853  31|82|aJahrg.|bHeft |i(year)
              # h	863  40|81.1|a1-32|b1-3|i1928-1933|jJan.-Juni|wn
              # h	863  40|82.2|a19-38|b1-2|i1961-1980
              it '(UNC) provides summary holdings statement' do
                expect(holdings3['holdings'][0]).to(
                  include("\"summary\":\"Bd.1:Heft 1 (Jan. 1928) - Bd.32:Heft 3 (Juni 1933); Jahrg.19:Heft 1 (1961) - Jahrg.38:Heft 2 (1980)")
                )
              end
            end

            context 'AND there is another pattern with no enumeration, only year/month/day chronology' do
              # y	853  |81|av.|bno.|i(year)|j(month)|k(day)
              # y	853  |82|a(year)|b(month)|c(day)
              # h	863  41|81.1|a1|b11|i1959|j04|k1
              # h	863  41|81.2|a1|b23|i1959|j06|k29
              # ...
              # h	863  41|82.10|a1961|b03|c27
              # h	863  41|82.11|a1961|b06|c26
              it '(UNC) provides summary holdings statement' do
                expect(holdings7['holdings'][0]).to(
                  include("\"summary\":\"v.1:no.11 (Apr. 1, 1959), v.1:no.23 (June 29, 1959), v.1:no.27 (July 27, 1959) - v.1:no.33 (Sept. 7, 1959), v.1:no.36 (Sept. 28, 1959), v.1:no.44 (Nov. 23, 1959) - v.1:no.49 (Dec. 28, 1959), v.2:no.1 (Jan. 4, 1960) - v.2:no.4 (Jan. 25, 1960), v.2:no.13 (Mar. 28, 1960), v.2:no.39 (Sept. 26, 1960), v.2:no.52 (Dec. 26, 1960); Mar. 27, 1961, June 26, 1961, Sept. 25, 1961, Dec. 25, 1961, Mar. 26, 1962, Dec. 31, 1962, Apr. 1, 1963, July 1, 1963, Sept. 30, 1963, Dec. 30, 1963, Feb. 24, 1964 - Oct. 11, 1965, Dec. 27, 1965 - Jan. 24, 1966, Mar. 28, 1966, June 27, 1966, Sept. 26, 1966, Dec. 26, 1966, Mar. 27, 1967, June 26, 1967, Sept. 25, 1967, Dec. 25, 1967, Feb. 26, 1968, Mar. 25, 1968, June 24, 1968, Sept. 30, 1968, Dec. 30, 1968, Mar. 31, 1969, June 30, 1969, Sept. 29, 1969, Dec. 29, 1969, Dec. 27, 1971, Mar. 27, 1972, June 26, 1972, Sept. 25, 1972, Dec. 25, 1972, Mar. 26, 1973, June 25, 1973, Sept. 24, 1973, Dec. 31, 1973, Jan. 7, 1974 - June 24, 1974, July 15, 1974 - Sept. 23, 1974, Oct. 14, 1974 - Dec. 23, 1974, Jan. 6, 1975, Jan. 20, 1975 - Feb. 10, 1975\"")
                )
              end
            end
          end
        end

        context 'There are 3 levels of enumeration' do
          context 'AND There is no chronology' do
            context 'AND Some 863s specify only partial enumeration' do
              # y	853  30|81|av.|bpt.|ct.
              # h	863  40|81.1|a1|wg
              # h	863  41|81.2|a4|b2|c1
              it '(UNC) provides summary holdings statement' do
                expect(holdings8['holdings'][0]).to(
                  include("\"summary\":\"v.1, v.4:pt.2:t.1\"")
                )
              end
            end
          end
          
          context 'AND There is a month/day/year chronology' do
            context 'AND There is a $z note unrelated to range' do
              # holdings6 - c4900227 - b6820876
              # y	853  |81|aaÃ±o |bMes |cno.|i(year)|j(month)|k(day)
              # h	863  30|81.1|a56-57|b8-1|c16.512-16.644|i1928|jmayo-oct.|k22-27|zSome issues missing
              it '(UNC) provides summary holdings statement' do
                expect(holdings6['holdings'][0]).to(
                  include("\"summary\":\"año 56:Mes 8:no.16.512 (mayo 22, 1928) - año 57:Mes 1:no.16.644 (oct. 27, 1928) Some issues missing")
                )
              end
            end
          end
        end
      end
    end
  end

  context 'When 868 with III field type = h are NOT present AND' do
    context 'There is at least one 855 with III field type = y AND' do
      context 'At least one 865 with III field type = h AND' do
        context 'There is a single level of enumeration AND' do
          context 'Year-only chronology AND' do
            it '(UNC) provides summary holdings statement' do
              # y	853  3|81|aaÃ±o |i(year)|gno.
              # y	855  |81|ano.|i(year)
              # h	863  30|81.1|a1|i1952|b1-8|zincomplete
              # h	863  40|81.2|a2-23|i1953-1974
              # h	865  41|81.3|a1-62|i1952-1961
              expect(holdings11['holdings'][0]).to(
                include("; Index holdings: no.1 (1952) - no.62 (1961)\"")
              )
            end

          end
        end
      end
    end
  end

    context 'When one set of enum/chron fields lacks $8 values' do
    it '(UNC) sets summary' do
      expect(holdings14['holdings'][0]).to(
        include("\"summary\":\"no.80, no.112, no.114 - no.115, no.119 - no.120, no.125, no.128, no.135, no.137, no.139, no.154, no.156 - no.158")
      )
      expect(holdings14['holdings'][1]).to(
        include("\"summary\":\"no.40 (1976) TO DATE")
      )
      expect(holdings14['holdings'][2]).to(
        include("\"summary\":\"no.145")
      )
    end
  end

    context 'When enumeration pattern has "(year)."' do
    it '(UNC) sets summary' do
      expect(holdings15['holdings'][0]).to(
        include("\"summary\":\"v.44:no.1 (2001), v.44:no.3 (2001) - v.44:no.4 (2001), v.45 (2003) - v.54 (2011)")
      )
      expect(holdings15['holdings'][1]).to(
        include("\"summary\":\"v.1 (1958) - v.2 (1959), v.3:no.2 (1960) - v.3:no.4 (1960), v.4 (1961) - v.32 (1989)")
      )
    end
  end

        context 'When enum/chron field has no data' do
    it '(UNC) sets summary' do
      expect(holdings15['holdings'][2]).to(
        include("\"summary\":\"v.27:no.1 (Jan. 1900) - v.27:no.5 (May 1900), v.53 (1921) - v.159 (1974)")
      )
    end
  end

        context 'When one data subfield of enum/chron field has no data' do
          it '(UNC) sets summary' do
            expect(holdings15['holdings'][3]).to(
              include("; Index holdings: v.25/28 (1982), v.29/33 (1983), v.34/38 (1984)")
            )
            expect(holdings15['holdings'][3]).to(
              include("\"summary\":\"v.3 (1976) - v.147 (Jan. 25, 1999)")
            )
          end
        end

        context 'When there is a full range given, but also an incomplete note' do
          it '(UNC) sets summary' do
            expect(holdings16['holdings'][0]).to(
              include("v.v.1 (1980) - v.2 (1981) Incomplete")
            )
          end
        end

        context 'When there is a full range given, but also an incomplete note' do
          it '(UNC) sets summary' do
            expect(holdings17['holdings'][0]).to(
              include("v.1 - v.105 incomplete; n.s. v.1 - n.s. v.62 incomplete")
            )
          end
        end
end
