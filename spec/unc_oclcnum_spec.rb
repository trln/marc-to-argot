require 'spec_helper'
describe MarcToArgot do
  include Util::TrajectRunTest
  let(:rec01) { run_traject_json('unc', 'oclcnum01') }
  let(:rec02) { run_traject_json('unc', 'oclcnum02') }
  let(:rec03) { run_traject_json('unc', 'oclcnum03') }
  let(:rec04) { run_traject_json('unc', 'oclcnum04') }
  let(:rec05) { run_traject_json('unc', 'oclcnum05') }
  let(:rec06) { run_traject_json('unc', 'oclcnum06') }
  let(:rec07) { run_traject_json('unc', 'oclcnum07') }
  let(:rec08) { run_traject_json('unc', 'oclcnum08') }
  let(:rec09) { run_traject_json('unc', 'oclcnum09') }
  let(:rec10) { run_traject_json('unc', 'oclcnum10') }
  let(:rec11) { run_traject_json('unc', 'oclcnum11') }
  let(:rec12) { run_traject_json('unc', 'oclcnum12') }
  let(:rec13) { run_traject_json('unc', 'oclcnum13') }
  let(:rec14) { run_traject_json('unc', 'oclcnum14') }
  let(:rec15) { run_traject_json('unc', 'oclcnum15') }
  let(:rec16) { run_traject_json('unc', 'oclcnum16') }
  let(:rec17) { run_traject_json('unc', 'oclcnum17') }
  let(:rec18) { run_traject_json('unc', 'oclcnum18') }
  let(:rec19) { run_traject_json('unc', 'oclcnum19') }
  let(:rec20) { run_traject_json('unc', 'oclcnum20') }

  # -=-=-=-=-=-=-=-
  # OCLC_NUMBER TESTS
  # -=-=-=-=-=-=-=-  
  it '(UNC) sets oclc_number when 001 is digits only and there is no 003' do
    expect(rec01['oclc_number']['value']).to(
      eq("825431")
    )
  end

  it '(UNC) sets oclc_number when 001 is digits only and 003 = OCoLC' do
    expect(rec02['oclc_number']['value']).to(
      eq("1001910954")
    )
  end

  it '(UNC) does NOT set oclc_number when 001 is digits only and 003 = ItFiC' do
    result = rec03['oclc_number']
    expect(result).to(
      eq(nil)
    )
  end

  it '(UNC) sets oclc_number from 035 with (OCoLC) when not set from 001' do
    result = [rec04['oclc_number']['value'], rec19['oclc_number']['value'], rec20['oclc_number']['value']]
    expect(result).to(
      eq(['1006424359', '560404564', '593657737'])
    )
  end

  it '(UNC) does NOT set oclc_number when 001 is digits only and 003 = DLC' do
    expect(rec05['oclc_number']).to(
      eq(nil)
    )
  end

  it '(UNC) strips leading zero(s) from oclc_number set from 035' do
    expect(rec06['oclc_number']['value']).to(
      eq('863862720')
    )
  end

  it '(UNC) does NOT set oclc_number when 001 is digits only and 003 = PWmBRO' do
    expect(rec07['oclc_number']).to(
      eq(nil)
    )
  end

  it '(UNC) sets oclc_number when 001 is digits only and 003 = NhCcYBP' do
    expect(rec08['oclc_number']['value']).to(
      eq('56651314')
    )
  end

  it '(UNC) sets oclc_number when 001 has prefix tmp and 003 = OCoLC' do
    expect(rec09['oclc_number']['value']).to(
      eq('54543095')
    )
  end

  it '(UNC) sets oclc_number when 001 is digits with alphanum suffix' do
    expect(rec10['oclc_number']['value']).to(
      eq('186568905')
    )
  end

  it '(UNC) does NOT set oclc_number when 001 has prefix M-ESTCN and 003 = OCoLC with prefixed 035' do
    expect(rec11['oclc_number']).to(
      eq(nil)
    )
  end

  it '(UNC) does NOT set oclc_number when 001 has prefix moml and 003 = OCoLC' do
    expect(rec12['oclc_number']).to(
      eq(nil)
    )
  end

  it '(UNC) sets oclc_number when 001 has hsl prefix and 003 = OCoLC' do
    expect(rec13['oclc_number']['value']).to(
      eq('228308541')
    )
  end

  it '(UNC) does NOT set oclc_number when 001 has WHO prefix and 003 = OCoLC' do
    expect(rec14['oclc_number']['value']).to(
      eq(nil)
    )
  end

  # -=-=-=-=-=-=-=-
  # SERSOL_NUMBER TESTS
  # -=-=-=-=-=-=-=-  
  # SSJ record appears to have OCLC# for e-journal in 035z without (OCoLC) prefix
  # However, I've not analyzed whether these records ever include other
  #  IDs coded the same way in 035.
  # Sticking with sersol_number as for rollup on these
  it '(UNC) does NOT set oclc_number, does set ssnumber when 001 has ssj prefix' do
    results = [rec15['oclc_number'], rec15['sersol_number']]
    expect(results).to(
      eq([nil, 'ssj0009206'])
    )
  end

  it '(UNC) does NOT set oclc_number, does set ssnumber when 001 has ssib prefix' do
    results = [rec16['oclc_number'], rec16['sersol_number']]
    expect(results).to(
      eq([nil, 'ssib019763752'])
    )
  end

  it '(UNC) does NOT set oclc_number, does set ssnumber when 001 has sse prefix' do
    results = [rec17['oclc_number'], rec17['sersol_number']]
    expect(results).to(
      eq([nil, 'ssj0001830521'])
    )
  end

  it '(UNC) does NOT set oclc_number, does set ssnumber when 001 has sseb prefix' do
    results = [rec18['oclc_number'], rec18['sersol_number']]
    expect(results).to(
      eq([nil, 'ssib026568724'])
    )
  end

  # -=-=-=-=-=-=-=-
  # ROLLUP TESTS
  # -=-=-=-=-=-=-=-  
  it '(UNC) sets OCLC number as rollup' do
    expect(rec01['rollup_id']).to(
      eq('OCLC825431')
    )
    end
    
  it '(UNC) sets first oclc_number_old value as rollup if other OCLC# is not available' do
    expect(rec14['rollup_id']).to(
      eq('OCLC761853943')
    )
    end
    
  it '(UNC) sets SerSol-based rollup' do
    expect(rec15['rollup_id']).to(
      eq('ssj0009206')
    )
  end

  # -=-=-=-=-=-=-=-
  # OCLC_NUMBER_OLD TESTS
  # -=-=-=-=-=-=-=-  
  it '(UNC) sets oclc_number_old from 019 with no cleanup' do
    result = [
              rec01['oclc_number']['old'],
              rec09['oclc_number']['old'],
              rec14['oclc_number']['old']
    ]
    expect(result).to(
      eq([
           ['1460998'],
           ['55956723'],
           ['761853943', '773174833']
         ])
    )
  end

  it '(UNC) sets oclc_number_old from 019 with suffix cleanup' do
    result = [
               rec10['oclc_number']['old']
             ]
    expect(result).to(
      eq([
           ['163280471', '171120795', '228150779']
         ])
    )
  end

  it '(UNC) do NOT set oclc_number_old from 019s with alpha prefixes' do
    result = [
               rec19['oclc_number']['old']
             ]
    expect(result).to(
      eq([
           nil
         ])
    )
  end

  # -=-=-=-=-=-=-=-
  # VENDOR_MARC_ID TESTS
  # -=-=-=-=-=-=-=-  
  it '(UNC) sets vendor_marc_id from 001 if oclc_number not set from 001 (before setting oclc_number from 035)' do
    result = [
              rec03['vendor_marc_id'],
              rec05['vendor_marc_id'],
              rec11['vendor_marc_id'],
              rec20['vendor_marc_id'],
              rec07['vendor_marc_id']
    ]
    expect(result).to(
      eq([
           ['4140888'],
           ['2014043145'],
           ['M-ESTCN14821814'],
           ['ASP1000005106/psyc'],
           ['2016950333']
         ])
    )
  end
end
