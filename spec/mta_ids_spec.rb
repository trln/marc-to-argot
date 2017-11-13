# coding: utf-8
require 'spec_helper'
describe MarcToArgot do
  ids01 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'ids01') )
  
  # -=-=-=-=-=-=-=-
  # 010 tests
  # -=-=-=-=-=-=-=-  
  it '(MTA) sets LCCN' do
    result = ids01['misc_id'][0]
    expect(result).to(
      eq({'value' => 'sn 78003579', 'qual' => '', 'type' => 'LCCN'})
    )
  end

  it '(MTA) sets NUCMC' do
    result = ids01['misc_id'][2]
    expect(result).to(
      eq({'value' => 'ms 69001649 ', 'qual' => '', 'type' => 'NUCMC'})
    )
  end

  # -=-=-=-=-=-=-=-
  # 015 tests
  # -=-=-=-=-=-=-=-  
  it '(MTA) sets national bib number (1 a, 1 q, 2 lookup)' do
    result = ids01['misc_id'][3]
    expect(result).to(
      eq({'value' => '123', 'qual' => 'v. 1', 'type' => "Bibliografía d'Andorra"})
    )
  end

  it '(MTA) sets national bib number (1 a containing qual, 0 q, no 2 lookup)' do
    result = [
      ids01['misc_id'][4],
      ids01['misc_id'][5],
      ids01['misc_id'][6]
    ]
    expect(result).to(
      eq([
           {'value' => '123', 'qual' => 'v. 1', 'type' => "National Bibliography Number"},
           {'value' => '789', 'qual' => 'v. 2', 'type' => "National Bibliography Number"},
           {'value' => '1010', 'qual' => '', 'type' => "National Bibliography Number"}
         ])
    )
  end

end
