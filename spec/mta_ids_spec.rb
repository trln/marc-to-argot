require 'spec_helper'
describe MarcToArgot do
  ids01 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'ids01') )
  
  # -=-=-=-=-=-=-=-
  # 010 tests
  # -=-=-=-=-=-=-=-  
  it '(MTA) sets LCCN' do
    result = [ids01['misc_id'][0], ids01['misc_id_qualifier'][0], ids01['misc_id_type'][0]]
    expect(result).to(
      eq(['sn 78003579', '', 'LCCN'])
    )
  end
end
