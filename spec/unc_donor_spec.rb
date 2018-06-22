require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:corpdonor1) { run_traject_json('unc', '791-1') }
  
  it '(UNC) sets a local note from 791 field with indicators 2b' do
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

end
