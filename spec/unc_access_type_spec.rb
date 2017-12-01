require 'spec_helper'

describe MarcToArgot do
  at01 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'access_type01') )
  at02 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'access_type02') )
  at03 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'access_type03') )
  at04 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'access_type04') )
  at05 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'access_type05') )
  at06 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'access_type06') )

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

    it '(UNC) access type = At Library if on order' do
    expect(at05['access_type']).to(
        eq(['At the Library'])
    )
    end

    it '(UNC) access type = At Library if held and no 856' do
    expect(at06['access_type']).to(
        eq(['At the Library'])
    )
    end    
end
