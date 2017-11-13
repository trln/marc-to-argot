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
end
