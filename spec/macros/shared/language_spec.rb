# coding: utf-8
require 'spec_helper'

include MarcToArgot::Macros::Shared::Helpers
include MarcToArgot::Macros::Shared::Language

describe MarcToArgot::Macros::Shared::Language do
  include Util

  it '(MTA) does not set language from 041h' do
    rec = make_rec
    rec['008'].value[35, 3] = 'eng'
    rec << MARC::DataField.new('041', '1', ' ', ['a', 'eng'], ['h', 'dan'])
    result = run_traject_on_record('unc', rec)['language']
    expect(result).to eq(
                        [
                          'English'
                        ]
                      )
  end

  context 'When item is translation (ind1 = 1)' do
    context 'AND $a is longer than 3 characters (legacy coding all in one subfield, often including lang of original)' do
      context 'AND no other usable 041 data present' do
      it '(MTA) does not set language from 041$a (assume 1st 041$a is same as 008 lang)' do
    rec = make_rec
    rec['008'].value[35, 3] = 'eng'
    rec << MARC::DataField.new('041', '1', ' ', ['a', 'engjpn'])
    result = run_traject_on_record('unc', rec)['language']
    expect(result).to eq(
                        [
                          'English'
                        ]
                      )
      end
      end

      context 'AND other usable 041 data present' do
        it '(MTA) sets language from all usable fields' do
          rec = make_rec
          rec['008'].value[35, 3] = 'dan'
          rec << MARC::DataField.new('041', '1', ' ',
                                     ['a', 'freeng'],
                                     ['h', 'lat'],
                                     ['b', 'ger'],
                                     ['e', 'belban'],
                                     ['h', 'bul'],
                                     ['g', 'bur'])
          result = run_traject_on_record('unc', rec)['language']
          expect(result).to eq(
                              [
                                'Danish',
                                'French',
                                'English',
                                'Belarusian',
                                'Balinese',
                                'Burmese'
                              ]
                            )
        end
      end
    end
  end

  context 'When item is NOT a translation (ind1 = 0)' do
    context 'AND $a is longer than 3 characters (legacy coding all in one subfield)' do
      it '(MTA) sets language from all 041$a values' do
          rec = make_rec
          rec['008'].value[35, 3] = 'eng'
          rec << MARC::DataField.new('041', '0', ' ',
                                     ['a', 'engfreitalat'])
          result = run_traject_on_record('unc', rec)['language']
          expect(result).to eq(
                              [
                                'English',
                                'French',
                                'Italian',
                                'Latin'
                              ]
                            )
      end
    end
  end
  
  describe 'get_008_lang_code' do
    context 'When there is a valid 008' do
      it 'gets 008/35-37 values' do
        rec = make_rec
        rec['008'].value[35, 3] = 'eng'
        expect(get_008_lang_code(rec)).to eq('eng')
      end
    end

    context 'When invalid 008 is too short to have lang code' do
      it 'returns nil' do
        rec = MARC::Record.new
        rec << MARC::ControlField.new('008', '     ')
        expect(get_008_lang_code(rec)).to be_nil
      end
    end
    
    context 'When there is no 008' do
      it 'returns nil' do
        rec = MARC::Record.new
        expect(get_008_lang_code(rec)).to be_nil
      end
    end
  end

  describe 'get_041_lang_codes' do
    context 'When ind2 = 7 (i.e. codes are not MARC lang codes)' do
      it 'Does NOT set codes from this field' do
        rec = make_rec
        rec << MARC::DataField.new('041', '0', '7', ['a', 'en'], ['h', 'de'])
        result = get_041_lang_codes(rec)
        expect(result).to be_nil
      end
    end

    context 'When ind2 = blank (i.e. codes are MARC lang codes)' do
      context 'When code is 3 characters long' do
        it 'Sets codes from this field' do
          rec = make_rec
          rec << MARC::DataField.new('041', '0', ' ', ['a', 'eng'])
          result = get_041_lang_codes(rec)
          expect(result).to eq(['eng'])
        end
      end
      context 'When code length (# of chars) is multiple of 3' do
        it 'Sets codes from this field' do
          rec = make_rec
          rec << MARC::DataField.new('041', '0', ' ', ['a', 'engfre'])
          result = get_041_lang_codes(rec)
          expect(result).to eq(['eng', 'fre'])
        end
      end
    end
  end

  describe 'keep_041_subfields' do
    it 'Keeps only subfields a, d, e, and g' do
      f = MARC::DataField.new('041', '0', ' ',
                              ['a', 'eng'],
                              ['a', 'ara'],
                              ['d', 'ita'],
                              ['h', 'ger'],
                              ['e', 'lat'],
                              ['p', 'spa'],
                              ['g', 'fre'])
      result = keep_041_subfields(f).map{ |sf| [sf.code, sf.value] }
      expect(result).to eq([['a', 'eng'],
                            ['a', 'ara'],
                            ['d', 'ita'],
                            ['e', 'lat'],
                            ['g', 'fre']
                           ])
    end
  end

  describe 'good_041_code_length?' do
    context 'When lang code length = 3 characters' do
      it 'returns true' do
        expect(good_041_code_length?('eng')).to eq(true)
      end
    end
    context 'When lang code length = a multiple of 3 characters' do
      it 'returns true' do
        expect(good_041_code_length?('engfrelat')).to eq(true)
      end
    end
    context 'When lang code length = 5' do
      it 'returns false' do
        expect(good_041_code_length?('engfr')).to eq(false)
      end
    end
    context 'When lang code length = 0' do
      it 'returns false' do
        expect(good_041_code_length?('')).to eq(false)
      end
    end
  end

  describe 'get_non_translation_lang_codes' do
    it 'returns all length-ok codes' do
      f = MARC::DataField.new('041', '0', ' ',
                                 ['a', 'freeng'],
                                 ['h', 'lat'],
                                 ['b', 'ger'],
                                 ['e', 'belban'],
                                 ['h', 'bul'],
                                 ['g', 'bur'])
      result = get_non_translation_lang_codes(f)
      expect(result).to eq(
                          [
                            'fre', 'eng',
                            'bel', 'ban', 'bur'
                          ]
                        )
    end
  end

  describe 'get_translation_lang_codes' do
    context 'When $a is the only usable subfield' do
    it 'returns only first code from $a' do
      f = MARC::DataField.new('041', '1', ' ',
                              ['a', 'freeng'],
                              ['h', 'lat'],
                              ['b', 'ger'],
                              ['h', 'bul'])
      result = get_translation_lang_codes(f)
      expect(result).to eq(['fre'])
    end
    end
    context 'When $a is NOT the only usable subfield' do
      it 'returns usable codes from all usable subfields' do
        f = MARC::DataField.new('041', '1', ' ',
                                ['a', 'freeng'],
                                ['d', 'latita'],
                                ['b', 'ger'],
                                ['h', 'bul'])
        result = get_translation_lang_codes(f)
        expect(result).to eq(['fre', 'eng', 'lat', 'ita'])
      end
    end
  end

  describe 'has_non_a_041_subfields?' do
    it 'Returns false when only usable subfield is a' do
      f = MARC::DataField.new('041', '1', ' ',
                              ['a', 'freeng'],
                              ['h', 'lat'],
                              ['b', 'ger'],
                              ['h', 'bul'])
      result = has_non_a_041_subfields?(f)
      expect(result).to eq(false)
    end
    it 'Returns true when usable subfield besides a present' do
      f = MARC::DataField.new('041', '1', ' ',
                              ['a', 'freeng'],
                              ['d', 'lat'],
                              ['b', 'ger'],
                              ['h', 'bul'])
      result = has_non_a_041_subfields?(f)
      expect(result).to eq(true)
    end
  end
  
  describe 'is_translation?' do
    context 'When ind1 = blank' do
      it 'returns true' do
        f = MARC::DataField.new('041', ' ', ' ', ['a', 'engfre'])
        expect(is_translation?(f)).to eq(true)
      end
    end
    context 'When ind1 = 0' do
      it 'returns false' do
        f = MARC::DataField.new('041', '0', ' ', ['a', 'engfre'])
        expect(is_translation?(f)).to eq(false)
      end
    end
    context 'When ind1 = 1' do
      it 'returns true' do
        f = MARC::DataField.new('041', '1', ' ', ['a', 'engfre'])
        expect(is_translation?(f)).to eq(true)
      end
    end
  end
  
  describe 'translate_codes' do
    context 'When all codes are valid and mappable' do
      it 'maps MARC language codes to language names' do
        codes = ['eng', 'fre', 'lat']
        expect(translate_codes(codes)).to eq(['English',
                                              'French',
                                              'Latin'])
      end
    end

    context 'When a code cannot be mapped' do
      it 'it is dropped from result as if code were not present' do
        codes = ['foo', 'eng']
        expect(translate_codes(codes)).to eq(['English'])
      end
    end
  end


end


