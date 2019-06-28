# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:internet_archive_id) { run_traject_json('duke', 'internet_archive_id', 'xml') }

  it '(MTA) sets the internet archive id from 955$q' do
    result = internet_archive_id['internet_archive_id']
    expect(result).to eq(['worksoflordbyron21byro', 'worksoflordbyron22byro'])
  end
end
