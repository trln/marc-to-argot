# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:troup1) { run_traject_json('unc', 'troup1', 'mrc') }
  let(:dwsgpo1) { run_traject_json('unc', 'dwsgpo1', 'mrc') }
  let(:dwsgpo2) { run_traject_json('unc', 'dwsgpo2', 'mrc') }
  let(:oupp1) { run_traject_json('unc', 'oupp1', 'mrc') }
  let(:asp1) { run_traject_json('unc', 'asp1', 'mrc') }
  let(:asp2) { run_traject_json('unc', 'asp2', 'mrc') }

  context 'When shared record set is OUPP' do
    it '(UNC) does NOT set TRLN location facet hierarchy for TRLN shared print' do
      result = troup1['location_hierarchy']
      expect(result).to eq(nil)
    end

    it '(UNC) record is assigned to all institutions' do
      result = oupp1['institution']
      expect(result).to eq(
                          ['unc', 'duke', 'nccu', 'ncsu']
                        )
    end

    it '(UNC) record_data_source includes "Shared Records" and "OUPP"' do
      result = oupp1['record_data_source']
      expect(result).to eq(
                          ['ILSMARC', 'Shared Records', 'OUPP']
                        )
    end

    it '(UNC) virtual_collection includes "TRLN Shared Records. Oxford University Press print titles."' do
      result = oupp1['virtual_collection']
      expect(result).to eq(
                          ['TRLN Shared Records. Oxford University Press print titles.']
                        )
    end
  end

  context 'When shared record set is DWS' do
    it '(UNC) record is assigned to all institutions' do
      result = dwsgpo1['institution']
      expect(result).to eq(
                          ['unc', 'duke', 'nccu', 'ncsu']
                        )
    end

    it '(UNC) sets open access URL' do
      result = dwsgpo1['url']
      expect(result).to include(
                          "{\"href\":\"http://purl.access.gpo.gov/GPO/LPS2957\",\"type\":\"fulltext\",\"restricted\":\"false\"}"                            
                      )
    end

    it '(UNC) sets open access URL without discarding $3 values' do
      result = dwsgpo2['url']
      expect(result).to include(
                          "{\"href\":\"http://purl.access.gpo.gov/GPO/LPS32255\",\"type\":\"fulltext\",\"text\":\"Spanish\",\"restricted\":\"false\"}"                            
                        )
    end
    
    it '(UNC) record_data_source includes "Shared Records" and "DWS"' do
      result = dwsgpo1['record_data_source']
      expect(result).to eq(
                          ['ILSMARC', 'Shared Records', 'DWS']
                        )
    end

    it '(UNC) virtual_collection includes "TRLN Shared Records. Documents without shelves."' do
      result = dwsgpo1['virtual_collection']
      expect(result).to eq(
                          ['TRLN Shared Records. Documents without shelves.']
                        )
    end

    it '(UNC) available value is Available' do
      result = dwsgpo1['available']
      expect(result).to eq(
                          "Available"
                        )
    end
  end


  context 'When shared record set is ASP' do
    it '(UNC) creates URL template for ASP recs' do
      result = asp1['url']
      expect(result).to eq(
                          [
                            "{\"href\":\"{proxyPrefix}https://www.aspresolver.com/aspresolver.asp?ANTH;764084\",\"type\":\"fulltext\"}"                            
                          ]
                        )
    end

    it '(UNC) keeps 856$3 values in url[text]' do
      result = asp2['url']
      expect(result).to eq(
                          [
                            "{\"href\":\"{proxyPrefix}https://www.aspresolver.com/aspresolver.asp?ANTH;764084\",\"type\":\"fulltext\",\"text\":\"Part 3\"}"                            
                          ]
                        )
    end
    it '(UNC) record is assigned to unc and duke only' do
      result = asp1['institution']
      expect(result).to eq(
                          ['unc', 'duke']
                        )
    end

    it '(UNC) record_data_source includes "Shared Records" and "ASP"' do
      result = asp1['record_data_source']
      expect(result).to eq(
                          ['ILSMARC', 'Shared Records', 'ASP']
                        )
    end

    it '(UNC) virtual_collection includes "TRLN Shared Records. Alexander Street Press videos."' do
      result = asp1['virtual_collection']
      expect(result).to eq(
                          ['TRLN Shared Records. Alexander Street Press videos.']
                        )
    end
  end

end
