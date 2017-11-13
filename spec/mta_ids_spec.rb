require 'spec_helper'
describe MarcToArgot do
  ids01 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'ids01') )
  
  # -=-=-=-=-=-=-=-
  # 010 tests
  # -=-=-=-=-=-=-=-  
  it '(MTA) sets LCCN' do
    result = ids01['misc_id'][0]
    expect(result).to(
      eq({'id' => 'sn 78003579', 'qual' => '', 'type' => 'LCCN'})
    )
  end

  it '(MTA) sets NUCMC' do
    result = ids01['misc_id'][2]
    expect(result).to(
      eq({'id' => 'ms 69001649', 'qual' => '', 'type' => 'NUCMC'})
    )
  end
end
