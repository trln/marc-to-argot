# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:troup1) { run_traject_json('unc', 'troup1', 'mrc') }
  let(:dwsgpo1) { run_traject_json('unc', 'dwsgpo1', 'mrc') }
  let(:oupp1) { run_traject_json('unc', 'oupp1', 'mrc') }
  let(:asp1) { run_traject_json('unc', 'asp1', 'mrc') }
  
  it '(MTA) does NOT set TRLN location hierarchy for TRLN shared print' do
    result = troup1['location_hierarchy']
    expect(result).to eq(nil)
  end

  xit '(MTA) sets all institutions on DWSGPO recs' do
    result = dwsgpo1['institution']
    expect(result).to eq(
                        ['unc', 'duke', 'nccu', 'ncsu']
                      )
  end

  it '(MTA) sets all institutions on OUPP recs' do
    result = oupp1['institution']
    expect(result).to eq(
                        ['unc', 'duke', 'nccu', 'ncsu']
                      )
  end

  it '(MTA) sets record_data_source on OUPP recs' do
    result = oupp1['record_data_source']
    expect(result).to eq(
                        ['ILSMARC', 'Shared Records', 'OUPP']
                      )
  end

  it '(MTA) sets virtual_collection on OUPP recs' do
    result = oupp1['virtual_collection']
    expect(result).to eq(
                        ['TRLN Shared Records. Oxford University Press print titles.']
                      )
  end
    
  xit '(MTA) creates Duke proxied URL for ASP recs' do
    result = asp1['url']
    expect(result).to include(
                        [
                          "{\"href\":\"http://proxy.lib.duke.edu/login?url=https://www.aspresolver.com/aspresolver.asp?ANTH;764084\",\"type\":\"fulltext\",\"text\":\"Streaming video available via Duke Libraries\"}"                            
                        ]
                      )
  end


end
