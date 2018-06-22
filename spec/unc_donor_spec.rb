require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:corpdonor1) { run_traject_json('unc', '791-1') }
  let(:donor2) { run_traject_json('unc', 'donor_personal1', 'mrc') }
  
  it '(UNC) sets donor from 791 field with indicators 2b' do
    expect(corpdonor1['donor']).to(
      eq([
           {
             'value' => 'Purchased using funds from the William A. Whitaker Foundation Library Fund.'
           },
           {
             'value' => 'Donated by Scaglione, Aldo D.'
           }
         ])
    )
  end

  it '(UNC) sets donor without including relators' do
    expect(donor2['donor']).to(
      eq([
           {
             'value' => 'Donated by Engstrom, Alfred G., 1907-1990'
           }
         ])
    )
  end

end
