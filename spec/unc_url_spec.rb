require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:at01) { run_traject_json('unc', 'access_type01') }
  
    it '(UNC) access type = Online if 856 i2=0' do
    expect(at01['access_type']).to(
        eq(['Online'])
    )
    end


end
