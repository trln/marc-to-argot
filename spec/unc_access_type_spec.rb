require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:at01) { run_traject_json('unc', 'access_type01') }
  let(:at02) { run_traject_json('unc', 'access_type02') }
  let(:at03) { run_traject_json('unc', 'access_type03') }
  let(:at04) { run_traject_json('unc', 'access_type04') }
  let(:at05) { run_traject_json('unc', 'access_type05') }
  let(:at06) { run_traject_json('unc', 'access_type06') }
  let(:at07) { run_traject_json('unc', 'access_type07') }
  
    it '(UNC) access type = Online if 856 i2=0' do
    expect(at01['access_type']).to(
        eq(['Online'])
    )
    end

    it '(UNC) access type = Online and At Library if 856 i2=1 and items' do
    expect(at02['access_type']).to(
        eq(['Online', 'At the Library'])
    )
    end    

    it '(UNC) access type = At Library if 856 i2=2 and items' do
    expect(at03['access_type']).to(
        eq(['At the Library'])
    )
    end    

    it '(UNC) access type = At Library if 856 i2=\ and items' do
    expect(at04['access_type']).to(
        eq(['At the Library'])
    )
    end    

    it '(UNC) access type not set if on order' do
    expect(at05['access_type']).to(
        eq(nil)
    )
    end

    it '(UNC) access type = At Library if held and no 856' do
    expect(at06['access_type']).to(
        eq(['At the Library'])
    )
    end    

    it '(UNC) access type = online only if 856 i2=0 and unsuppressed order record' do
    expect(at07['access_type']).to(
        eq(['Online'])
    )
    end    
end
