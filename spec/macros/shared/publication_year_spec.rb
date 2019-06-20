# coding: iso-8859-1

require 'spec_helper'
include MarcToArgot::Macros::Shared::PublicationYear

describe MarcToArgot do
  include Util::TrajectRunTest


  describe MarcToArgot::Macros::Shared::PublicationYear do
    describe 'usable_date? - determine whether a given date value is usable for deriving a reasonable single value for sorting/filtering' do

      it '1997 is usable - 4 digits, in usable range' do
        v = usable_date?('1997', 500, 2024)
        expect(v).to eq(true)
      end

      it '688 is usable - fewer than 4 digits, but in usable range' do
        v = usable_date?('688 ', 500, 2024)
        expect(v).to eq(true)
      end

      it '9999 is usable - gets translated into current year + 1' do
        v = usable_date?('9999', 500, 2024)
        expect(v).to eq(true)
      end

      it '499 is NOT usable - out of usable range' do
        v = usable_date?('499', 500, 2024)
        expect(v).to eq(false)
      end

      it '6754 is NOT usable - 4 digits, but out of usable range' do
        v = usable_date?('6754', 500, 2024)
        expect(v).to eq(false)
      end

      it '1uuu is NOT usable - indicates only the millennium' do
        v = usable_date?('uuuu', 500, 2024)
        expect(v).to eq(false)
      end

      it 'uuuu is NOT usable - unknown date' do
        v = usable_date?('uuuu', 500, 2024)
        expect(v).to eq(false)
      end
    end

    describe 'is_range? - determine whether a single date value from fixed field should be interpreted as a range' do
      it '1997 is not a range: 4 digit date' do
        v1 = is_range?('1997', 'fixed_field')
        expect(v1).to eq(false)
      end
      it '199u is a range: decade' do
        v2 = is_range?('199u', 'fixed_field')
        expect(v2).to eq(true)
      end
      it '19uu is a range: century' do
        v3 = is_range?('19uu', 'fixed_field')
        expect(v3).to eq(true)
      end
      it 'uuuu is not a range: unknown' do
        v4 = is_range?('uuuu', 'fixed_field')
        expect(v4).to eq(false)
      end
      it '198| is not a range: 3 digit date' do
        v5 = is_range?('198|', 'fixed_field')
        expect(v5).to eq(false)
      end
      it '66u| is a range: 3 digit date, decade known' do
        v6 = is_range?('66u|', 'fixed_field')
        expect(v6).to eq(true)
      end
    end
    
    describe 'is_range? - determine whether a single date value from variable field should be interpreted as a range' do
      it '1997 is not a range: 4 digit date' do
        v1 = is_range?('1997', 'var_field')
        expect(v1).to eq(false)
      end
      it '199- is a decade range' do
        v2 = is_range?('199-', 'var_field')
        expect(v2).to eq(true)
      end
      it '19-- is a century range' do
        v3 = is_range?('19--', 'var_field')
        expect(v3).to eq(true)
      end
      it '1--- is a millennium range' do
        v4 = is_range?('1---', 'var_field')
        expect(v4).to eq(true)
      end
      it '198? is not a range: it is a best guess at the specific date' do
        v5 = is_range?('198?', 'var_field')
        expect(v5).to eq(false)
      end
    end

    describe 'get_date - translate a fixed field date into a single value for further processing if it is usable, and discard it completely from further processing if it is unusable' do
      it '19uu returns 1949 -- midpoint of range 1900-1999' do
        d = get_date('19uu', 's' , 500, 2024, 'fixed_field', 500)
        expect(d).to eq(1949)
      end

      it '688 returns 688 -- no translation necessary' do
        d = get_date('688', 's' , 500, 2024, 'fixed_field', 500)
        expect(d).to eq(688)
      end

      it '9876 returns nil -- not a usable date for further processing' do
        d = get_date('9876', 's' , 500, 2024, 'fixed_field', 500)
        expect(d).to be_nil
      end
    end
    
    describe 'get_date  - translate a variable field date into a single value for further processing if it is usable, and discard it completely from further processing if it is unusable' do
      context 'WHEN 008/06 is not c, d, or u' do
      it '197- returns 1974 -- midpoint of range 1970-1979' do
        d = get_date('197-', 's' , 500, 2024, 'var_field', 500)
        expect(d).to eq(1974)
      end

      it '688 returns 688 -- no translation necessary' do
        d = get_date('688', 's' , 500, 2024, 'var_field', 500)
        expect(d).to eq(688)
      end

      it '9876 returns nil -- not a useful date for further processing' do
        d = get_date('9876', 's' , 500, 2024, 'var_field', 500)
        expect(d).to be_nil
      end

      it 'c1999 returns 1999 -- extract only digits, followed by -' do
        d = get_date('c1999', 's' , 500, 2024, 'var_field', 500)
        expect(d).to eq(1999)
      end

      it '-2018 returns 2018 -- extracts only digits, followed by -' do
        d = get_date('-2018', 'd' , 500, 2024, 'var_field', 500)
        expect(d).to eq(2018)
      end

      it '192-- (extra hyphen) returns 1924 -- extra hyphen ignored when figuring midpoint of range' do
        d = get_date('192--', 's' , 500, 2024, 'var_field', 500)
        expect(d).to eq(1924)
      end

      it '[197-?] returns 1974 -- ignores brackets and terminal question mark' do
        d = get_date('[197-?]', 's' , 500, 2024, 'var_field', 500)
        expect(d).to eq(1974)
      end
      it '[2017];©2018 returns 2017 -- takes only the first date' do
        d = get_date('[2017];©2018', 't' , 500, 2024, 'var_field', 500)
        expect(d).to eq(2017)
      end
      it '[between 1950 and 1959?] returns 1950 -- takes only the first date' do
        d = get_date('[between 1950 and 1959?]', 's' , 500, 2024, 'var_field', 500)
        expect(d).to eq(1950)
      end
      it '\'-December 16, 2014.\' returns 2014 -- takes only the year' do
        d = get_date('-December 16, 2014.', 's' , 500, 2024, 'var_field', 500)
        expect(d).to eq(2014)
      end
      it '[n.d.] returns nil -- no recognized year pattern found' do
        d = get_date('[n.d.]', 's' , 500, 2024, 'var_field', 500)
        expect(d).to be_nil
      end
      end
      context 'WHEN 008/06 is c, d, or u' do
        it '192-- (extra hyphen indicating open date range) returns 1924 -- extra hyphen ignored when figuring midpoint of range' do
          d = get_date('192--', 'c' , 500, 2024, 'var_field', 500)
          expect(d).to eq(1924)
        end
        it '[2017];©2018 returns 2018 -- takes only the final year date' do
          d = get_date('[2017];©2018', 'd' , 500, 2024, 'var_field', 500)
          expect(d).to eq(2018)
        end

      end
    end
    
    describe 'midpoint_or_usable - called when it looks like there is a range. Given the two dates derived using the get_date logic, tries to return the logical midpoint or otherwise usable value from the range' do
      it '1850, 9999: returns 1850, use date1 if date2=9999' do
        d = midpoint_or_usable(1850, 9999)
        expect(d).to eq(1850)
      end
      it '1850, 1900: returns 1875, the midpoint between dates since date1 < date2' do
        d = midpoint_or_usable(1850, 1900)
        expect(d).to eq(1875)
      end
      it '2000, 1984: returns 2000, since date1 > date2 (which is not a reasonable range!)' do
        d = midpoint_or_usable(1850, 1900)
        expect(d).to eq(1875)
      end
      it '1894, 1894: returns 1894, sincd date1 = date2 (which is not a range)' do
        d = midpoint_or_usable(1894, 1894)
        expect(d).to eq(1894)
      end
      it '1894, nil: returns 1894, the only usable date given' do
        d = midpoint_or_usable(1894, nil)
        expect(d).to eq(1894)
      end
      it 'nil, 2019: returns 2019, the only usable date given' do
        d = midpoint_or_usable(nil, 2019)
        expect(d).to eq(2019)
      end
    end

    # 9999 should translate to current year + 1
    let (:continuing_resource_max) { Time.now.year + 1 }

    context 'LOGIC BASED ON DATE TYPE AND OTHER FACTORS (\\ indicates a blank character)' do
      context 'WHEN DateType = b (No dates given; B.C. date involved)' do
        context 'AND no 260 or 264 having dates' do
          it '(MTA) pub date not set' do
            rec = make_rec
            val = rec['008'].value
            val[6] = 'b'
            val[7..10] = '1975'
            rec['008'].value = val
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to be_nil
          end
        end

        context 'AND record has 260 with |cp1999' do
          it '(MTA) pub date = 1999' do
            rec = make_rec
            val = rec['008'].value
            val[6] = 'b'
            val[7..10] = '1975'
            rec['008'].value = val
            rec << MARC::DataField.new('260', ' ',  ' ', ['c', '1999'])
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1999])
          end
        end

        context 'AND record has 264\0 with |c1999, followed by 264\1 with |c2000' do
          it '(MTA) pub date = 2000 (uses date from preferred 260 or 264)' do
            rec = make_rec
            val = rec['008'].value
            val[6] = 'b'
            val[7..10] = '1975'
            rec['008'].value = val
            rec << MARC::DataField.new('264', ' ',  '0', ['c', '1999'])
            rec << MARC::DataField.new('264', ' ',  '1', ['c', '2000'])
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([2000])
          end
        end
      end

      context 'WHEN DateType = c (Continuing resource currently published)' do
        context 'AND date2=9999' do
          it '(MTA) pub date = current year+1 (use translated date2 if it is a usable date)' do
            rec = make_rec
            rec['008'].value[6..14] = 'c20129999'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([continuing_resource_max])
          end
        end
        context 'AND date2=2018' do
          it '(MTA) pub date = 2018 (use translated date2 if it is a usable date)' do
            rec = make_rec
            rec['008'].value[6..14] = 'c20122018'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([2018])
          end
        end
        context 'AND date2=2uuu' do
          context 'AND no 260/264 date present' do
          it '(MTA) pub date = nil (millennium range not usable, will not set pub date from date1 since that would poorly represent the currency of a currently published continuing resource)' do
            rec = make_rec
            rec['008'].value[6..14] = 'c19002uuu'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to be_nil
          end
          end
          context 'AND 260/264 date = |c1900-200-' do
            it '(MTA) pub date = nil (millennium range not usable, will not set pub date from date1 since that would poorly represent the currency of a currently published continuing resource; gets last date from 26X and treats as range)' do
              rec = make_rec
              rec['008'].value[6..14] = 'c19002uuu'
              rec << MARC::DataField.new('260', ' ', ' ', ['c', '1900-200-'])              
              argot = run_traject_on_record('unc', rec)
              expect(argot['publication_year']).to eq([2004])
            end
          end
        end
        end

      context 'WHEN DateType = d (Continuing resource ceased publication)' do
        context 'AND dates = \\\\\\\\1949' do
          it '(MTA) pub date = 1949 (date2 if present and usable, to represent the most current material that was published, since there is no start date)' do
            rec = make_rec
            rec['008'].value[6..14] = 'd    1949'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1949])
          end
        end
        context 'AND dates = 194519uu' do
          it '(MTA) pub date = 1972 (assuming pub cannot cease before beginning, midpoint of date2 treated as 1945-1999)' do
            rec = make_rec
            rec['008'].value[6..14] = 'd194519uu'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1972])
          end
        end
        context 'AND dates = 1945\\\\\\\\' do
          context 'AND no 260/264 date present' do
          it '(MTA) pub date = nil (will not set pub date from date1 because it would poorly represent the ultimate currency of a later-ceased continuing resource)' do
            rec = make_rec
            rec['008'].value[6..14] = 'd1945    '
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to be_nil
          end
          end
          context 'AND 260 with |c1945-1984. present' do
          it '(MTA) pub date = 1984 (will not set pub date from date1 because it would poorly represent the ultimate currency of a later-ceased continuing resource; takes last year recorded in 26X)' do
            rec = make_rec
            rec['008'].value[6..14] = 'd1945    '
            rec << MARC::DataField.new('260', ' ', ' ', ['c', '1945-1984.'])
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1984])
          end
          end
        end
        context 'AND dates = 19459999' do
          it '(MTA) pub year = current year (assume record marked ceased without adding ceased date in error, and that such an error would be caught somewhat soon)' do
            rec = make_rec
            rec['008'].value[6..14] = 'd19459999'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([Time.new.year])
          end
        end
        end

      context 'WHEN DateType = e (Detailed date)' do
        context 'AND dates = 20120215' do
          it '(MTA) pub date = 2012 (usable date1)' do
            rec = make_rec
            rec['008'].value[6..14] = 'e20120215'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([2012])
          end
        end
        context 'AND dates = 02120215 (date1 typo for 2012)' do
          context 'AND 260 with |c2/15/2012 present' do
            it '(MTA) pub date = 2012 (date1 unusable, cannot set year from date2, take year from first 260/264' do
              rec = make_rec
              rec['008'].value[6..14] = 'e02120215'
              rec << MARC::DataField.new('260', ' ', ' ', ['c', '2/15/2012.'])
              argot = run_traject_on_record('unc', rec)
              expect(argot['publication_year']).to eq([2012])
            end
          end
          context 'AND no 260/264 date present' do
            it '(MTA) pub date = nil (date1 unusable, cannot set year from date2)' do
              rec = make_rec
              rec['008'].value[6..14] = 'e02120215'
              argot = run_traject_on_record('unc', rec)
              expect(argot['publication_year']).to be_nil
            end
          end
        end
      end

      context 'WHEN DateType = i (Inclusive dates of collection)' do
        context 'AND dates = 19101950' do
          it '(MTA) pub date = 1910 (use date1)' do
            rec = make_rec
            rec['008'].value[6..14] = 'i19101950'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1910])
          end
        end
        context 'AND dates = 1uuu1950' do
          context 'AND no 260/264 date present' do
            it '(MTA) pub date = nil (do not set date from date2)' do
              rec = make_rec
              rec['008'].value[6..14] = 'i1uuu1950'
              argot = run_traject_on_record('unc', rec)
              expect(argot['publication_year']).to be_nil
            end
          end
          context 'AND 260/264 has |c1910 to 1950' do
            it '(MTA) pub date = 1910 (do not set date from date2; get first date from 26X field)' do
              rec = make_rec
              rec['008'].value[6..14] = 'i1uuu1950'
              rec << MARC::DataField.new('260', ' ', ' ', ['c', '1910 to 1950.'])
              argot = run_traject_on_record('unc', rec)
              expect(argot['publication_year']).to eq([1910])
            end
          end
        end
      end

        context 'WHEN DateType = k (Range of years of bulk of collection)' do
          it '(MTA) works the same way as DateType = i (set only from date1 or first 26X date)' do
            rec = make_rec
            rec['008'].value[6..14] = 'k19101950'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1910])
          end
        end

        context 'WHEN DateType = m (Multiple dates)' do
          context 'AND dates = 19662000' do
          it '(MTA) pub date = 2000 (prefer date2 if it is a usable, non-9999 date' do
            rec = make_rec
            rec['008'].value[6..14] = 'm19662000'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([2000])
          end
          end
          context 'AND dates = 19669999' do
            it '(MTA) pub date = 1966 (use date1 if date2 = 9999)' do
              rec = make_rec
              rec['008'].value[6..14] = 'm19669999'
              argot = run_traject_on_record('unc', rec)
              expect(argot['publication_year']).to eq([1966])
            end
          end
          context 'AND dates = 198u9999' do
            it '(MTA) pub date = 1984 (use date1, treating as range if necessary, if date2 is unusable' do
            rec = make_rec
            rec['008'].value[6..14] = 'm198u2uuu'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1984])
            end
          end
          context 'AND dates = \\\\\\\\9999' do
            context 'AND no 260/4 date present' do
              it '(MTA) pub date = nil (no usable dates -- 9999 not considered usable for this date type)' do
                rec = make_rec
                rec['008'].value[6..14] = 'm    9999'
                argot = run_traject_on_record('unc', rec)
                expect(argot['publication_year']).to be_nil
              end
            end
            context 'AND 260/264 has |c1910, 1950' do
              it '(MTA) pub date = 1950 (get final date from best 26X field)' do
                rec = make_rec
                rec['008'].value[6..14] = 'm    9999'
                rec << MARC::DataField.new('260', ' ', ' ', ['c', '1910, 1950.'])
                argot = run_traject_on_record('unc', rec)
                expect(argot['publication_year']).to eq([1950])
              end
            end
          end
        end

        context 'WHEN DateType = n (Dates unknown)' do
          context 'AND dates = 18501900' do
            it '(MTA) pub date = 1875 (use midpoint between the two usable dates)' do
              rec = make_rec
              rec['008'].value[6..14] = 'n18501900'
              argot = run_traject_on_record('unc', rec)
              expect(argot['publication_year']).to eq([1875])
            end
          end
          context 'AND dates = n19661966' do
            it '(MTA) pub date = 1966 (use date1 if date2 = date1)' do
              rec = make_rec
              rec['008'].value[6..14] = 'n19661966'
              argot = run_traject_on_record('unc', rec)
              expect(argot['publication_year']).to eq([1966])
            end
          end
          context 'AND dates = n20001950' do
            it '(MTA) pub date = 2000 (use date1 if date2 > date1)' do
              rec = make_rec
              rec['008'].value[6..14] = 'n20001950'
              argot = run_traject_on_record('unc', rec)
              expect(argot['publication_year']).to eq([2000])
            end
          end
          context 'AND dates = n19842uuu' do
            it '(MTA) pub date = 1984 (use date1 if date2 unusable)' do
            rec = make_rec
            rec['008'].value[6..14] = 'n19842uuu'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1984])
            end
          end
          context 'AND dates = n1uuu2018' do
            it '(MTA) pub date = 2018 (use date2 if date1 unusable)' do
            rec = make_rec
            rec['008'].value[6..14] = 'n1uuu2018'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([2018])
            end
          end
          context 'AND dates = n1uuu2uuu' do
            context 'AND no 260/4 dates present' do
              it '(MTA) pub date = nil (no usable dates)' do
                rec = make_rec
                rec['008'].value[6..14] = 'n1uuu2uuu'
                argot = run_traject_on_record('unc', rec)
                expect(argot['publication_year']).to be_nil
              end
            context 'AND 260/264 has |c1910, 1950' do
              it '(MTA) pub date = 1910 (get initial date from best 26X field)' do
                rec = make_rec
                rec['008'].value[6..14] = 'n1uuu2uuu'
                rec << MARC::DataField.new('260', ' ', ' ', ['c', '1910, 1950.'])
                argot = run_traject_on_record('unc', rec)
                expect(argot['publication_year']).to eq([1910])
              end
            end
            end
          end
        end

        context 'WHEN DateType = p (Date of distribution/release/issue and production/recording session when different)' do
          it '(MTA) works the same as DateType = m (preferences date2)' do
            rec = make_rec
            rec['008'].value[6..14] = 'p20182000'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([2000])

            rec = make_rec
            rec['008'].value[6..14] = 'p19669999'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1966])

            rec = make_rec
            rec['008'].value[6..14] = 'p1984uuuu'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1984])
          end
        end

        context 'WHEN DateType = q (Questionable date)' do
          it '(MTA) works the same as DateType = n' do
            rec = make_rec
            rec['008'].value[6..14] = 'q10001199'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1099])

            rec = make_rec
            rec['008'].value[6..14] = 'q19661966'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1966])
            rec['008'].value[6..14] = 'q20001950'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([2000])

            rec = make_rec
            rec['008'].value[6..14] = 'q    1932'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1932])
          end
        end

        context 'WHEN DateType = r (Reprint/reissue date and original date)' do
          it '(MTA) works the same as DateType = m (preferences date2)' do
            rec = make_rec
            rec['008'].value[6..14] = 'r20182000'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([2000])

            rec = make_rec
            rec['008'].value[6..14] = 'r19669999'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1966])

            rec = make_rec
            rec['008'].value[6..14] = 'r1984uuuu'
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1984])
          end
        end

        context 'WHEN DateType = s (Single known date/probable date)' do
          it '(MTA) works the same way as DateType = i (set only from date1 or first 26X date)' do
            rec = make_rec
            rec['008'].value[6..14] = 's2012    '
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([2012])

            rec = make_rec
            rec['008'].value[6..14] = 's201u    '
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([2014])

            rec = make_rec
            rec['008'].value[6..14] = 's19uu    '
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([1949])

            rec = make_rec
            rec['008'].value[6..14] = 's20uu    '
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([(2000 + Time.new.year)/2])

            rec = make_rec
            rec['008'].value[6..14] = 's1uuu    '
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to be_nil
          end
        end

        context 'WHEN DateType = t (Publication date and copyright date)' do
          it '(MTA) works the same way as DateType = i (set only from date1 or first 26X date)' do
            rec = make_rec
            rec['008'].value[6..14] = 't2012    '
            argot = run_traject_on_record('unc', rec)
            expect(argot['publication_year']).to eq([2012])
          end
        end

        context 'WHEN DateType = u (Continuing resource status unknown)' do
          context 'AND dates = 20129999' do
            it '(MTA) pub date = current year + 1 (9999 used in its translated form)' do
              rec = make_rec
              rec['008'].value[6..14] = 'u20129999'
              argot = run_traject_on_record('unc', rec)
              expect(argot['publication_year']).to eq([continuing_resource_max])
            end
          end
          context 'AND dates = 19002uuu' do
            it '(MTA) pub date = 1900 (use date1 if no usable date2)' do
              rec = make_rec
              rec['008'].value[6..14] = 'u19002uuu'
              argot = run_traject_on_record('unc', rec)
              expect(argot['publication_year']).to eq([1900])
            end
          end
          context 'AND dates = 1uuu2uuu' do
            context 'AND 260/4 has |c1989 through 2017.' do
              it '(MTA) pub date = 2017 (use final 260/4 date if no useable 008 date)' do
                rec = make_rec
                rec['008'].value[6..14] = 'u1uuu2uuu'
                rec << MARC::DataField.new('260', ' ', ' ', ['c', '1989 through 2017.'])
                argot = run_traject_on_record('unc', rec)
                expect(argot['publication_year']).to eq([2017])
              end
            end
          end
        end
    end

      describe 'choose_ff_date' do
        it 'returns preferred date if present' do
          d = choose_ff_date(1999, 1995, false)
          expect(d).to eq(1999)
        end
        it 'returns fallback date if preferred date not present' do
          d = choose_ff_date(nil, 1995, false)
          expect(d).to eq(1995)
        end
        it 'returns fallback date if preferred date is invalid 9999' do
          d = choose_ff_date(9999, 1995, false)
          expect(d).to eq(1995)
        end
        it 'returns nil if both dates are missing or an invalid 9999' do
          d = choose_ff_date(9999, nil, false)
          expect(d).to be_nil
        end
        it 'returns 9999 from preferred date if 9999 is valid' do
          d = choose_ff_date(9999, 1980, true)
          expect(d).to eq(9999)
        end
      end

    end
  end
