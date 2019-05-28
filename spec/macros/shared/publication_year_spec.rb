# coding: utf-8

require 'spec_helper'
include MarcToArgot::Macros::Shared::PublicationYear

describe MarcToArgot do
  include Util::TrajectRunTest
  describe MarcToArgot::Macros::Shared::PublicationYear do

    # 9999 should translate to current year + 1
    let (:continuing_resource_max) { Time.now.year + 1 }

    context 'DateType = b' do
      context 'AND no 260/4 date' do
        it '(MTA) does not set date' do
          rec = make_rec
          val = rec['008'].value
          val[6] = 'b'
          val[7..10] = '1975'
          rec['008'].value = val
          argot = run_traject_on_record('unc', rec)
          expect(argot['publication_year']).to be_nil
        end
      end

      context 'AND 260/4 date' do
        it '(MTA) sets date from 260/4' do
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
    end

    context 'DateType = c' do
      it '(MTA) sets from usable date2 if present' do
        rec = make_rec
        rec['008'].value[6..14] = 'c20129999'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([continuing_resource_max])
      end
      it '(MTA) does not set from unusable date2' do
        rec = make_rec
        rec['008'].value[6..14] = 'c19002uuu'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to be_nil
      end
    end

    context 'DateType = d' do
      it '(MTA) sets from usable date2 if present' do
        rec = make_rec
        rec['008'].value[6..14] = 'd    1949'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1949])
      end
      it '(MTA) sets from date2 range not beginning before date1' do
        rec = make_rec
        rec['008'].value[6..14] = 'd194519uu'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1972])
      end
      it '(MTA) does not fall over if date2 blank' do
        rec = make_rec
        rec['008'].value[6..14] = 'd1945    '
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to be_nil
      end
      it '(MTA) sets current year if date2 = 9999' do
        rec = make_rec
        rec['008'].value[6..14] = 'd19459999'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([Time.new.year])
      end
    end

    context 'DateType = e' do
      context 'AND no 260/4 date' do
        it '(MTA) sets from usable date1' do
          rec = make_rec
          rec['008'].value[6..14] = 'e20120215'
          argot = run_traject_on_record('unc', rec)
          expect(argot['publication_year']).to eq([2012])
        end
        it '(MTA) does not set from unusable date1' do
          rec = make_rec
          rec['008'].value[6..14] = 'e||||0215'
          argot = run_traject_on_record('unc', rec)
          expect(argot['publication_year']).to be_nil
        end
      end
    end

    context 'DateType = i' do
      it '(MTA) sets from usable date1' do
        rec = make_rec
        rec['008'].value[6..14] = 'i19101950'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1910])
      end
    end

    context 'DateType = k' do
      it '(MTA) sets from usable date1' do
        rec = make_rec
        rec['008'].value[6..14] = 'k19101950'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1910])
      end
    end

    context 'DateType = m' do
      it '(MTA) sets from non-9999 date2' do
        rec = make_rec
        rec['008'].value[6..14] = 'm19662000'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([2000])
      end
      it '(MTA) sets from date1 if date2 = 9999' do
        rec = make_rec
        rec['008'].value[6..14] = 'm19669999'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1966])
      end
      it '(MTA) sets from date1 if date2 otherwise unusable' do
        rec = make_rec
        rec['008'].value[6..14] = 'm19842uuu'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1984])
      end
    end

    context 'DateType = n' do
      it '(MTA) if usable range, sets midpoint' do
        rec = make_rec
        rec['008'].value[6..14] = 'n18501900'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1875])
      end
      it '(MTA) uses date1 if both dates present but equal or date1 later' do
        rec = make_rec
        rec['008'].value[6..14] = 'n19661966'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1966])
        rec['008'].value[6..14] = 'n20001950'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([2000])
      end
      it '(MTA) sets from date1 if date2 unusable' do
        rec = make_rec
        rec['008'].value[6..14] = 'n19842uuu'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1984])
      end
    end

    context 'DateType = p' do
      it '(MTA) sets from non-9999 date2' do
        rec = make_rec
        rec['008'].value[6..14] = 'p20182000'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([2000])
      end
      it '(MTA) sets from date1 if date2 = 9999' do
        rec = make_rec
        rec['008'].value[6..14] = 'p19669999'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1966])
      end
      it '(MTA) sets from date1 if date2 otherwise unusable' do
        rec = make_rec
        rec['008'].value[6..14] = 'p1984uuuu'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1984])
      end
    end

    context 'DateType = q' do
      it '(MTA) if usable range, sets midpoint' do
        rec = make_rec
        rec['008'].value[6..14] = 'q10001199'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1099])
      end
      it '(MTA) uses date1 if both dates present but equal or date1 later' do
        rec = make_rec
        rec['008'].value[6..14] = 'q19661966'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1966])
        rec['008'].value[6..14] = 'q20001950'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([2000])
      end
      it '(MTA) sets from date2 if date1 unusable' do
        rec = make_rec
        rec['008'].value[6..14] = 'q    1932'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1932])
      end
    end

    context 'DateType = r' do
      it '(MTA) sets from non-9999 date2' do
        rec = make_rec
        rec['008'].value[6..14] = 'r20182000'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([2000])
      end
      it '(MTA) sets from date1 if date2 = 9999' do
        rec = make_rec
        rec['008'].value[6..14] = 'r19669999'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1966])
      end
      it '(MTA) sets from date1 if date2 otherwise unusable' do
        rec = make_rec
        rec['008'].value[6..14] = 'r1984uuuu'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1984])
      end
    end

    context 'DateType = s' do
      context 'AND no 260/4 date' do
        it '(MTA) sets from usable full year date1' do
          rec = make_rec
          rec['008'].value[6..14] = 's2012    '
          argot = run_traject_on_record('unc', rec)
          expect(argot['publication_year']).to eq([2012])
        end
        it '(MTA) sets from usable date1 decade range' do
          rec = make_rec
          rec['008'].value[6..14] = 's201u    '
          argot = run_traject_on_record('unc', rec)
          expect(argot['publication_year']).to eq([2014])
        end
        it '(MTA) sets from usable date1 century range' do
          rec = make_rec
          rec['008'].value[6..14] = 's19uu    '
          argot = run_traject_on_record('unc', rec)
          expect(argot['publication_year']).to eq([1949])
        end
        it '(MTA) sets from usable date1 century range (this century)' do
          rec = make_rec
          rec['008'].value[6..14] = 's20uu    '
          argot = run_traject_on_record('unc', rec)
          expect(argot['publication_year']).to eq([(2000 + Time.new.year)/2])
        end
        it '(MTA) does not consider date1 millenium range usable' do
          rec = make_rec
          rec['008'].value[6..14] = 's1uuu    '
          argot = run_traject_on_record('unc', rec)
          expect(argot['publication_year']).to be_nil
        end
      end
    end

    context 'DateType = t' do
      it '(MTA) sets from usable date1' do
        rec = make_rec
        rec['008'].value[6..14] = 't2012    '
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([2012])
      end
    end

    context 'DateType = u' do

      it '(MTA) sets from usable date2 if present --- 9999 is considered usable' do
        rec = make_rec
        rec['008'].value[6..14] = 'u20129999'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([continuing_resource_max])
      end
      it '(MTA) sets from usable date1 if no usable date2' do
        rec = make_rec
        rec['008'].value[6..14] = 'u19002uuu'
        argot = run_traject_on_record('unc', rec)
        expect(argot['publication_year']).to eq([1900])
      end
    end

    describe 'usable_date?' do
      it 'returns true if 4 digits and in range' do
        v = usable_date?('1997', 500, 2024)
        expect(v).to eq(true)
      end

      it 'returns true if fewer than 4 digits, but in range' do
        v = usable_date?('666 ', 500, 2024)
        expect(v).to eq(true)
      end

      it 'returns false if 4 digits and out of range' do
        v = usable_date?('6754', 500, 2024)
        expect(v).to eq(false)
      end

      it 'returns false if uuuu' do
        v = usable_date?('uuuu', 500, 2024)
        expect(v).to eq(false)
      end

      it 'returns true if 9999' do
        v = usable_date?('9999', 500, 2024)
        expect(v).to eq(true)
      end
    end

    describe 'is_range?' do
      it 'works for fixed field u dates' do
        v1 = is_range?('1997', 'fixed_field')
        v2 = is_range?('199u', 'fixed_field')
        v3 = is_range?('19uu', 'fixed_field')
        v4 = is_range?('uuuu', 'fixed_field')
        v5 = is_range?('198|', 'fixed_field')
        v6 = is_range?('66u|', 'fixed_field')
        expect(v1).to eq(false)
        expect(v2).to eq(true)
        expect(v3).to eq(true)
        expect(v4).to eq(false)
        expect(v5).to eq(false)
        expect(v6).to eq(true)
      end
      
      it 'works for variable field u dates' do
        v1 = is_range?('1997', 'var_field')
        v2 = is_range?('199-', 'var_field')
        v3 = is_range?('19--', 'var_field')
        v4 = is_range?('1---', 'var_field')
        v5 = is_range?('198?', 'var_field')
        expect(v1).to eq(false)
        expect(v2).to eq(true)
        expect(v3).to eq(true)
        expect(v4).to eq(true)
        expect(v5).to eq(false)
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

    describe 'midpoint_or_usable' do
      it 'returns midpoint between dates if both dates present' do
        d = midpoint_or_usable(1850, 1900)
        expect(d).to eq(1875)
      end
      it 'does not consider 9999 a usable date' do
        d = midpoint_or_usable(1850, 9999)
        expect(d).to eq(1850)
      end
      it 'chooses single date if only one is usable' do
        d = midpoint_or_usable(1894, nil)
        expect(d).to eq(1894)
      end
      it 'chooses single date if both dates are identical' do
        d = midpoint_or_usable(1894, 1894)
        expect(d).to eq(1894)
      end
    end
    
    describe 'get_date (fixed fields)' do
      it 'treats uncertain date as range' do
        d = get_date('19uu', 500, 2024, 'fixed_field', 500)
        expect(d).to eq(1949)
      end

      it 'populates usable non-range date' do
        d = get_date('666', 500, 2024, 'fixed_field', 500)
        expect(d).to eq(666)
      end

      it 'returns nil if date is not usable' do
        d = get_date('9876', 500, 2024, 'fixed_field', 500)
        expect(d).to be_nil
      end
    end
    
    describe 'get_date (var fields)' do
      it 'treats uncertain date as range' do
        d = get_date('197-', 500, 2024, 'var_field', 500)
        expect(d).to eq(1974)
      end

      it 'populates usable non-range date' do
        d = get_date('666', 500, 2024, 'var_field', 500)
        expect(d).to eq(666)
      end

      it 'returns nil if date is not usable' do
        d = get_date('9876', 500, 2024, 'var_field', 500)
        expect(d).to be_nil
      end

      it 'extracts 1999 from \'c1999\'' do
        d = get_date('c1999', 500, 2024, 'var_field', 500)
        expect(d).to eq(1999)
      end

      it 'extracts 2018 from \'-2018\'' do
        d = get_date('-2018', 500, 2024, 'var_field', 500)
        expect(d).to eq(2018)
      end

      it 'extracts 1974 from \'197--\'' do
        d = get_date('197--', 500, 2024, 'var_field', 500)
        expect(d).to eq(1974)
      end

      it 'extracts 1974 from \'[197-?]\'' do
        d = get_date('[197-?]', 500, 2024, 'var_field', 500)
        expect(d).to eq(1974)
      end
      it 'extracts 2017 from \'[2017];©2018\'' do
        d = get_date('[2017];©2018', 500, 2024, 'var_field', 500)
        expect(d).to eq(2017)
      end
      it 'extracts 1950 from \'[between 1950 and 1959?]\'' do
        d = get_date('[between 1950 and 1959?]', 500, 2024, 'var_field', 500)
        expect(d).to eq(1950)
      end
      it 'extracts 2014 from \'-December 16, 2014.\'' do
        d = get_date('-December 16, 2014.', 500, 2024, 'var_field', 500)
        expect(d).to eq(2014)
      end
      it 'returns nil when there is no date match' do
        d = get_date('[n.d.]', 500, 2024, 'var_field', 500)
        expect(d).to be_nil
      end
    end
  end
end
