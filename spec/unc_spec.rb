require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:b1082803argot) { run_traject_json('unc', 'b1082803') }
  let(:b1246383argot) { run_traject_json('unc', 'b1246383') }
  let(:b1319986argot) { run_traject_json('unc', 'b1319986') }
  let(:cat_date) { run_traject_json('unc', 'cat_date') }
  
  it '(UNC) does not set virtual collection from 919$a' do
    expect(b1082803argot['virtual_collection']).to(
      eq(nil)
    )
  end

  it '(UNC) sets virtual collection from 919$t' do
    expect(b1246383argot['virtual_collection']).to(
      eq(['testcoll'])
    )
  end

  it '(UNC) sets virtual collection from repeated 919$t' do
    expect(b1319986argot['virtual_collection']).to(
      eq(['testcoll', 'anothercoll'])
    )
  end

  it '(UNC) sets date_cataloged' do
    expect(cat_date['date_cataloged']).to(
      eq(['2004-10-01T04:00:00Z'])
    )
  end
end
