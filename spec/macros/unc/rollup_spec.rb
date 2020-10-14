# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::Shared::Helpers
include MarcToArgot::Macros::UNC::Rollup

describe MarcToArgot::Macros::UNC::Rollup do
  include Util

  context 'When there is NO OCLC number (current or old), SerialsSolutions number, or vendor number in record' do
    let(:argot) {
      rec = make_rec
      argot = run_traject_on_record('unc', rec)
    }
    
    it '(UNC) does not set oclc_number field' do
      result = argot['oclc_number']
      expect(result).to be_nil
    end
    it '(UNC) does not set sersol_number field' do
      result = argot['sersol_number']
      expect(result).to be_nil
    end
    it '(UNC) does not set vendor_marc_id field' do
      result = argot['vendor_marc_id']
      expect(result).to be_nil
    end
    it '(UNC) does not set rollup_id' do
      result = argot['rollup_id']
      expect(result).to be_nil
    end
    it '(UNC) does not set primary_oclc' do
      result = argot['primary_id']
      expect(result).to be_nil
    end
  end
  
  context 'When there is a current OCLC number data in record' do
    let(:argot) {
      rec = make_rec
      rec << MARC::ControlField.new('001', '1234')
      rec << MARC::ControlField.new('003', '')
      rec << MARC::DataField.new('019', ' ', ' ',
                                 ['a', '2222'])
      argot = run_traject_on_record('unc', rec)
    }
    
    it '(UNC) sets oclc_number field' do
      result = argot['oclc_number']
      expect(result).to eq({ 'value' => '1234',
                             'old' => ['2222'] })
    end
    it '(UNC) sets rollup_id from oclc_number' do
      result = argot['rollup_id']
      expect(result).to eq('OCLC1234')
    end

    it '(UNC) sets primary_oclc from oclc_number' do
      result = argot['primary_oclc']
      expect(result).to eq('1234')
    end
  end

  context 'When there is a current OCLC number data in record and 035$q includes exclude' do
    let(:argot) {
      rec = make_rec
      rec << MARC::ControlField.new('001', '1234')
      rec << MARC::ControlField.new('003', '')
      rec << MARC::DataField.new('019', ' ', ' ',
                                 ['a', '2222'])
      rec << MARC::DataField.new('035', ' ', ' ',
                                 ['a', '2222'],
                                 ['q', 'exclude'])
      argot = run_traject_on_record('unc', rec)
    }
    
    it '(UNC) sets oclc_number field' do
      result = argot['oclc_number']
      expect(result).to eq({ 'value' => '1234',
                             'old' => ['2222'] })
    end
    it '(UNC) sets rollup_id from oclc_number' do
      result = argot['rollup_id']
      expect(result).to eq('OCLC1234')
    end

    it '(UNC) sets primary_oclc to nil' do
      result = argot['primary_oclc']
      expect(result).to be_nil
    end
  end

  context 'When there is NO current OCLC number data in record' do
    context 'AND there is old OCLC number in record' do
      let(:argot) {
        rec = make_rec
        rec << MARC::ControlField.new('003', '')
        rec << MARC::DataField.new('019', ' ', ' ',
                                   ['a', '2222'],
                                   ['a', '3333'])
        argot = run_traject_on_record('unc', rec)
      }
      
      it '(UNC) sets oclc_number field' do
        result = argot['oclc_number']
        expect(result).to eq({ 'value' => '',
                               'old' => ['2222', '3333'] })
      end
      it '(UNC) sets rollup_id from first oclc_number[old] value' do
        result = argot['rollup_id']
        expect(result).to eq('OCLC2222')
      end
    end

    context 'AND there is NO old OCLC number in record' do
      context 'AND there is a SerialsSolutions number in record' do
        let(:argot) {
          rec = make_rec
          rec << MARC::ControlField.new('001', 'sseb123')
          rec << MARC::ControlField.new('003', '')
          argot = run_traject_on_record('unc', rec)
        }

        it '(UNC) does NOT set oclc_number field' do
          result = argot['oclc_number']
          expect(result).to be_nil
        end
        it '(UNC) does NOT set primary_oclc field' do
          result = argot['primary_oclc']
          expect(result).to be_nil
        end
        it '(UNC) sets sersol_number' do
          expect(argot['sersol_number']).to eq('ssib123')
        end
        it '(UNC) sets rollup_id from sersol_number' do
          result = argot['rollup_id']
          expect(result).to eq('ssib123')
        end
      end

      context 'AND there is NO SerialsSolutions number in record' do
        context 'AND there is a vendor id number in record' do
          let(:argot) {
            rec = make_rec
            rec << MARC::ControlField.new('001', 'EBC308382sub')
            rec << MARC::ControlField.new('003', 'MiAaPQ')
            argot = run_traject_on_record('unc', rec)
          }

          it '(UNC) does NOT set oclc_number field' do
            result = argot['oclc_number']
            expect(result).to be_nil
          end
          it '(UNC) does NOT set primary_oclc' do
            result = argot['primary_oclc']
            expect(result).to be_nil
          end
          it '(UNC) does NOT set sersol_number' do
            expect(argot['sersol_number']).to be_nil
          end
          it '(UNC) sets vendor_marc_id' do
            expect(argot['vendor_marc_id']).to eq(['EBC308382'])
          end
          it '(UNC) sets rollup_id from vendor_marc_id' do
            result = argot['rollup_id']
            expect(result).to eq('EBC308382')
          end
        end
      end
    end
  end

  describe 'get_id_data' do
    it '(UNC) creates hash populated with 001, 003, 019, and 035 data used to assign ids' do
      rec = make_rec
      rec << MARC::ControlField.new('001', '1234')
      rec << MARC::ControlField.new('003', 'abc')
      rec << MARC::DataField.new('019', ' ', ' ',
                                 ['a', '2222'],
                                 ['a', '3333'],
                                 ['o', 'S-123'])
      rec << MARC::DataField.new('035', ' ', ' ',
                                 ['a', '(aaa)4444'],
                                 ['z', '(aaa)5555'])
      rec << MARC::DataField.new('035', ' ', ' ',
                                 ['a', '(zzz)6666'],
                                 ['z', '(zzz)7777'])

      id_data = get_id_data(rec)
      expect(id_data).to eq({
                              '001' => '1234',
                              '003' => 'abc',
                              '019' => ['2222', '3333'],
                              '035' => ['(aaa)4444', '(zzz)6666'],
                              "035q"=>[],
                              '035z' => ['(aaa)5555', '(zzz)7777']
                            })
    end

    it '(UNC) creates empty hash if usable 001, 003, 019, and 035 data not present' do
      rec = make_rec
      rec << MARC::DataField.new('019', ' ', ' ',
                                 ['o', 'S-123'])
      rec << MARC::DataField.new('035', ' ', ' ',
                                 ['q', '(aaa)5555'])
      rec << MARC::DataField.new('035', ' ', ' ',
                                 ['q', '(zzz)7777'])

      id_data = get_id_data(rec)
      expect(id_data).to eq({
                              '001' => '',
                              '003' => '',
                              '019' => [],
                              '035' => [],
                              '035z' => [],
                              '035q' => ["(aaa)5555", "(zzz)7777"]
                            })
    end
  end

  describe 'set_oclc_number' do
    it 'returns hash value of Argot oclc_number field if either or both subelement (value, old) will be populated' do
      id_data = { '001' => '123', '003' => 'OCoLC', '019' => ['222', '333'], '035' => [], '035z' => [] }
      expect(set_oclc_number(id_data)).to eq({ 'value' => '123', 'old' => ['222', '333'] })
      id_data = { '001' => '', '003' => '', '019' => ['222', '333'], '035' => [], '035z' => [] }
      expect(set_oclc_number(id_data)).to eq({ 'value' => '', 'old' => ['222', '333'] })
      id_data = { '001' => '123', '003' => 'OCoLC', '019' => [], '035' => [], '035z' => [] }
      expect(set_oclc_number(id_data)).to eq({ 'value' => '123', 'old' => [] })
    end
    it 'returns nil if neither current nor old oclc numbers can be set' do
      id_data = { '001' => 'EEBO123', '003' => '', '019' => [], '035' => [], '035z' => [] }
      expect(set_oclc_number(id_data)).to be_nil
    end
  end

  describe 'set_sersol_number' do
    it 'returns sseb id as ssib id' do
      id_data = { '001' => 'sseb123', '003' => 'WaSeSS', '019' => [], '035' => [], '035z' => [] }
      expect(set_sersol_number(id_data)).to eq('ssib123')
    end
    it 'returns sse id as ssj id' do
      id_data = { '001' => 'sse123', '003' => 'WaSeSS', '019' => [], '035' => [], '035z' => [] }
      expect(set_sersol_number(id_data)).to eq('ssj123')
    end
    it 'returns nil if no SerialsSolutions id present' do
      id_data = { '001' => '', '003' => '', '019' => [], '035' => [], '035z' => [] }
      expect(set_sersol_number(id_data)).to be_nil
    end
  end

  describe 'set_vendor_id' do
    it 'returns vendor ids from 001' do
      id_data = { '001' => 'EBC445424sub',
                  '003' => 'MiAaPQ',
                  '019' => [],
                  '035' => ['(OCoLC)437140401'],
                  '035z' => [] }
      expect(set_vendor_id(id_data)).to eq(['EBC445424'])
    end
    it 'returns vendor ids from 019, deduplicating repeated ids' do
      id_data = { '001' => 'EBC445424sub',
                  '003' => 'MiAaPQ',
                  '019' => ['EBC445424'],
                  '035' => [],
                  '035z' => [] }
      expect(set_vendor_id(id_data)).to eq(['EBC445424'])
    end
    it 'returns vendor ids from 035, deduplicating repeated ids' do
      id_data = { '001' => 'EBC445424sub',
                  '003' => 'MiAaPQ',
                  '019' => ['ebr10167445'],
                  '035' => ['(MiAaPQ)EBC445424',
                            '(Au-PeEL)EBL445424',
                            '(CaONFJC)MIL212944',
                            '(OCoLC)437140401'],
                  '035z' => [] }
      expect(set_vendor_id(id_data)).to eq(['EBC445424', 'EBR10167445', 'EBL445424', 'MIL212944'])
    end
    it 'returns nil if there are no vendor ids' do
      id_data = { '001' => '',
                  '003' => '',
                  '019' => [],
                  '035' => ['(OCoLC)437140401'],
                  '035z' => [] }
      expect(set_vendor_id(id_data)).to be_nil
    end
  end
  
  describe 'set_rollup' do
    it 'returns nil if there are no source numbers' do
      result = set_rollup(nil, nil, nil)
      expect(result).to be_nil
    end
  end

  describe 'get_oclc_number' do
    context 'When 001 value is digits only' do
      context 'AND there is no 003' do
        it '(UNC) set oclc_number from 001' do
          id_data = { '001' => '123', '003' => '', '019' => [], '035' => [], '035z' => [] }
          result = get_oclc_number(id_data)
          expect(result).to eq('123')
        end
      end

      context 'AND 003 = OCoLC' do
        it '(UNC) set oclc_number from 001' do
          id_data = { '001' => '123', '003' => 'OCoLC', '019' => [], '035' => [], '035z' => [] }
          result = get_oclc_number(id_data)
          expect(result).to eq('123')
        end
      end

      context 'AND 003 = NhCcYBP' do
        it '(UNC) set oclc_number from 001' do
          id_data = { '001' => '123', '003' => 'NhCcYBP', '019' => [], '035' => [], '035z' => [] }
          result = get_oclc_number(id_data)
          expect(result).to eq('123')
        end
      end

      context 'AND there is NO OCLC number in 035' do
        context 'AND 003 = ItFiC' do
          it '(UNC) does NOT set oclc_number' do
            id_data = { '001' => '123', '003' => 'ItFiC', '019' => [], '035' => [], '035z' => [] }
            result = get_oclc_number(id_data)
            expect(result).to be_nil
          end
        end


        context 'AND 003 = DLC' do
          it '(UNC) does NOT set oclc_number' do
            id_data = { '001' => '123', '003' => 'DLC', '019' => [], '035' => [], '035z' => [] }
            result = get_oclc_number(id_data)
            expect(result).to be_nil
          end
        end

        context 'AND 003 = PwmBRO' do
          it '(UNC) does NOT set oclc_number' do
            id_data = { '001' => '123', '003' => 'PWmBRO', '019' => [], '035' => [], '035z' => [] }
            result = get_oclc_number(id_data)
            expect(result).to be_nil
          end
        end
      end
    end

    context 'When 001 = alphabetic prefix, followed by digits' do
      context 'AND prefix is ssj, ssib, sse, or sseb' do
        context 'AND 035$z consisting only of digits is present' do
          it '(UNC) sets oclc_number from 035$z' do
            id_data = { '001' => 'ssj0002091230', '003' => 'WaSeSS', '019' => [], '035' => [], '035z' => ['213387618'] }
            result = get_oclc_number(id_data)
            expect(result).to eq('213387618')
          end
        end
        context 'AND 035$z consisting only of digits NOT present' do
          it '(UNC) does NOT set oclc_number' do
            id_data = { '001' => 'ssib001151830', '003' => 'WaSeSS', '019' => [], '035' => [], '035z' => ['(WaSeSS)ssib001151830'] }
            result = get_oclc_number(id_data)
            expect(result).to be_nil
          end
        end
        context 'AND 035$a beginning with (OCoLC) is present' do
          it '(UNC) sets oclc_number from 035$a' do
            id_data = { '001' => 'sseb123', '003' => 'WaSeSS', '019' => [], '035' => ['(OCoLC)666'], '035z' => [] }
            result = get_oclc_number(id_data)
            expect(result).to eq('666')
          end
          context 'AND that 035$a value is digits followed by alpha suffix' do
            it '(UNC) strips alpha suffix from end of 035$a' do
              id_data = { '001' => 'GPVL9933522196501551', '003' => 'CMalG', '019' => [], '035' => ['(OCoLC)874575136gpvl'], '035z' => [] }
              result = get_oclc_number(id_data)
              expect(result).to eq('874575136')
            end
          end
        end
      end
      
      context 'AND 003 = OCoLC' do 
        it '(UNC) sets oclc_number from 001 if prefix is: tmp' do
          id_data = { '001' => 'tmp123', '003' => 'OCoLC', '019' => [], '035' => [], '035z' => [] }
          result = get_oclc_number(id_data)
          expect(result).to eq('123')
        end

        it '(UNC) sets oclc_number from 001 if prefix is: hsl' do
          id_data = { '001' => 'hsl123', '003' => 'OCoLC', '019' => [], '035' => [], '035z' => [] }
          result = get_oclc_number(id_data)
          expect(result).to eq('123')
        end

        it '(UNC) does NOT set oclc_number from 001 when prefix is: moml ' do
          id_data = { '001' => 'moml123', '003' => 'OCoLC', '019' => [], '035' => [], '035z' => [] }
          result = get_oclc_number(id_data)
          expect(result).to be_nil
        end

        it '(UNC) does NOT set oclc_number from 001 when prefix is: WHO' do
          id_data = { '001' => 'WHO123', '003' => 'OCoLC', '019' => [], '035' => [], '035z' => [] }
          result = get_oclc_number(id_data)
          expect(result).to be_nil
        end
      end
    end

    context 'When 001 = digits followed by alphanumeric suffix' do
      context 'AND 003 = OCoLC' do
        it '(UNC) sets oclc_number from 001' do
          id_data = { '001' => '186568905wcmSPR2016', '003' => 'OCoLC', '019' => [], '035' => [], '035z' => [] }
          result = get_oclc_number(id_data)
          expect(result).to eq('186568905')
        end
      end
      context 'AND there is no 003' do
        it '(UNC) sets oclc_number from 001' do
          id_data = { '001' => '186568905wcmSPR2016', '003' => '', '019' => [], '035' => [], '035z' => [] }
          result = get_oclc_number(id_data)
          expect(result).to eq('186568905')
        end
      end
    end

    context 'When there is no OCLC number in 001' do
      context 'AND there is an OCLC number in an 035' do
        it '(UNC) sets oclc_number from the 035 having (OCoLC)' do
          id_data = { '001' => '123',
                      '003' => 'ItFiC',
                      '019' => [],
                      '035' => ['(OCoLC)100', '(EBR)321'],
                      '035z' => [] }
          result = get_oclc_number(id_data)
          expect(result).to eq('100')
        end

        context 'BUT the OCLC 035 value has prefix: (OCoLC)M-ESTCN' do
          it '(UNC) does NOT set oclc_number from this 035' do
            id_data = { '001' => 'M-ESTCN123', '003' => 'OCoLC', '019' => [], '035' => ['(OCoLC)M-ESTCN123'], '035z' => [] }
            result = get_oclc_number(id_data)
            expect(result).to be_nil
          end
        end
      end
      
      context 'AND there are OCLC numbers in multiple 035s' do
        it '(UNC) sets oclc_number from the first 035 having (OCoLC)' do
          id_data = { '001' => '123',
                      '003' => 'ItFiC',
                      '019' => [],
                      '035' => ['(OCoLC)100', '(EBR)321', '(OCoLC)200'],
                      '035z' => [] }
          result = get_oclc_number(id_data)
          expect(result).to eq('100')
        end
      end
    end
  end

  describe 'get_oclc_number_old' do
    it 'returns array of cleaned 019a values' do
      id_data = { '001' => '',
                  '003' => 'OCoLC',
                  '019' => ['ocm222', '333wcm2018', '444'],
                  '035' => [],
                  '035z' => [] }
      result = get_oclc_number_old(id_data)
      expect(result).to eq(['222', '333', '444'])
    end
    it 'omits non-OCLC 019s' do
      id_data = { '001' => 'EBC308382sub',
                  '003' => 'MiAaPQ',
                  '019' => ['ebr10167445'],
                  '035' => ['(OCoLC)560404564'],
                  '035z' => [] }
      result = get_oclc_number_old(id_data)
      expect(result).to be_nil
    end
  end

  describe 'oclc_001?' do
    it '(UNC) true when 001 is digits only AND there is no 003' do
      result = oclc_001?('123', '')
      expect(result).to eq(true)
    end
    it '(UNC) true when 001 is digits only AND 003 is OCoLC' do
      result = oclc_001?('123', 'OCoLC')
      expect(result).to eq(true)
    end
    it '(UNC) true when 001 is digits only AND 003 is NhCcYBP' do
      result = oclc_001?('123', 'NhCcYBP')
      expect(result).to eq(true)
    end
    it '(UNC) true when 001 is tmp + digits AND 003 is OCoLC' do
      result = oclc_001?('tmp123', 'OCoLC')
      expect(result).to eq(true)
    end
    it '(UNC) false when 001 is tmp + digits AND 003 is blank' do
      result = oclc_001?('tmp123', '')
      expect(result).to eq(false)
    end
    it '(UNC) false when 001 is digits only AND 003 is non-OCLC pattern' do
      result = oclc_001?('123', 'blah')
      expect(result).to eq(false)
    end
  end

  describe 'oclc_001_pattern?' do
    it '(UNC) true when cleaned 001 value is digits only' do
      expect(oclc_001_pattern?('123')).to eq(true)
    end
    it '(UNC) true when cleaned 001 value begins with tmp or hsl, followed by digits' do
      expect(oclc_001_pattern?('tmp123')).to eq(true)
      expect(oclc_001_pattern?('hsl123')).to eq(true)
    end
    it '(UNC) false when cleaned 001 value begins with ebr, followed by digits' do
      expect(oclc_001_pattern?('ebr123')).to eq(false)
    end
  end

  describe 'oclc_003?' do
    it '(UNC) returns true if 003 is blank, OCoLC, or NhCcYBP (ignoring case and space); false otherwise' do
      result = [oclc_003?(''),
                oclc_003?('OCoLC '),
                oclc_003?('NhCcYbp'),
                oclc_003?('blah')]
      expect(result).to eq([true, true, true, false])
    end
  end

  describe 'get_oclc_035s' do
    it '(UNC) selects only OCoLC values from 035' do
      result = get_oclc_035s(['(OCoLC)123', '(ocolc)123', '(ebr)567'])
      expect(result).to eq(['(OCoLC)123', '(ocolc)123'])
    end
    it '(UNC) does not consider (OCoLC)M-ESTCN14821814 to be an OCLC 035 value' do
      result = get_oclc_035s(['(OCoLC)M-ESTCN14821814'])
      expect(result).to be_nil
    end
    it '(UNC) returns nil if no OCLC 035s' do
      result = get_oclc_035s(['(a)123', '(b)123', '(ebr)567'])
      expect(result).to be_nil
    end
    it '(UNC) returns nil if no 035s' do
      result = get_oclc_035s([])
      expect(result).to be_nil
    end
  end
  
  describe 'clean_001_or_019' do
    it '(UNC) removes ocm, ocn, or on (ignoring case, spaces) from beginning of value' do
      result = [clean_001_or_019('OCM123'),
                clean_001_or_019(' ocn222'),
                clean_001_or_019('on333'),
                clean_001_or_019('a444ocn')]
      expect(result).to eq(['123', '222', '333', 'a444ocn'])
    end
    it '(UNC) removes alphanumeric suffix from end of digits-only value' do
      result = [clean_001_or_019('OCM123abc'),
                clean_001_or_019(' 222abc3'),
                clean_001_or_019('ab333zz')]
      expect(result).to eq(['123', '222', 'ab333zz'])
    end
    it '(UNC) passes EBR number through as-is' do
      result = [clean_001_or_019('ebr123')]
      expect(result).to eq(['ebr123'])
    end
  end

  describe 'clean_035' do
    it '(UNC) removes parenthetical qualifier from beginning of value' do
      result = [clean_035(' (OCoLC)123'),
                clean_035('(OCoLC)ocn222'),
                clean_035('(OCOLC)333'),
                clean_035('(whatever)444')]
      expect(result).to eq(['123', '222', '333', '444'])
    end
    it '(UNC) removes ocm, ocn, or on (ignoring case, spaces) from beginning of value after parenthetical is removed' do
      result = [clean_035('OCM123'),
                clean_035(' ocn222'),
                clean_035('on333'),
                clean_035('a444ocn')]
      expect(result).to eq(['123', '222', '333', 'a444ocn'])
    end
  end

  describe 'clean_oclc_number' do
    it '(UNC) removes tmp and hsl prefixes from OCLC numbers' do
      result = [clean_oclc_number(' tmp123'),
                clean_oclc_number('hsl222')]
      expect(result).to eq(['123', '222'])
    end
    it '(UNC) removes leading zeros from OCLC numbers' do
      result = [clean_oclc_number(' tmp0000123'),
                clean_oclc_number('0333')]
      expect(result).to eq(['123', '333'])
    end
  end

  describe 'clean_vendor_id' do
    it 'capitalizes all alphabetic characters' do
      expect(clean_vendor_id('ebl123')).to eq('EBL123')
    end
    it 'removes sub and dda suffixes' do
      result = [
        clean_vendor_id('EBC123dda'),
        clean_vendor_id('EBC234sub'),
        clean_vendor_id('ASP1000005106/psyc')
      ]
      expect(result).to eq(['EBC123', 'EBC234', 'ASP1000005106/PSYC'])
    end
  end
end
