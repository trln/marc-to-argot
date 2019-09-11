# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::UNC::SharedRecords

describe MarcToArgot::Macros::UNC::SharedRecords do
  include Util::TrajectRunTest
  let(:troup1) { run_traject_json('unc', 'troup1', 'mrc') }
  let(:dwsgpo1) { run_traject_json('unc', 'dwsgpo1', 'mrc') }
  let(:dwsgpo2) { run_traject_json('unc', 'dwsgpo2', 'mrc') }
  let(:oupp1) { run_traject_json('unc', 'oupp1', 'mrc') }

  describe 'id_shared_record_set' do
    it 'identifies CRL records' do
      rec = make_rec
      rec << MARC::DataField.new('773', '0', ' ',
                                 ['t', 'Center for Research Libraries (CRL) eResources (online collection)']
                                )
      result = id_shared_record_set(rec)
      expect(result).to eq('crl')
    end

    it 'identifies OUPP records' do
      rec = make_rec
      rec << MARC::DataField.new('919', ' ', ' ', ['a', 'TROUP'])
      result = id_shared_record_set(rec)
      expect(result).to eq('oupp')
    end

    it 'does NOT identify ASP records' do
      rec = make_rec
      rec << MARC::DataField.new('919', ' ', ' ',
                                 ['a', 'ASPSVFLON']
                                )
      result = id_shared_record_set(rec)
      expect(result).to be_nil
    end

    it 'does NOT identify filmfinder records' do
      rec = make_rec
      rec << MARC::DataField.new('919', ' ', ' ', ['a', 'filmfinder'])
      result = id_shared_record_set(rec)
      expect(result).to be_nil
    end
  end

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

    context 'When non-OUPP items are present on a OUPP record' do
      let(:rec) do
        rec = make_rec
        rec << MARC::DataField.new('919', ' ', ' ', ['a', 'TROUP'])
        rec << MARC::DataField.new('999', '9', '1', ['l', "ddda"])
        rec << MARC::DataField.new('999', '9', '1', ['l', "troup"])
        rec
      end

      it '(UNC) non-OUPP items are removed' do
        result = run_traject_on_record('unc', rec)['items']
        expect(result.find { |i| i.include? 'ddda' }).to be_nil
      end

      it '(UNC) OUPP items remain' do
        result = run_traject_on_record('unc', rec)['items']
        expect(result.find { |i| i.include? "loc_b\":\"troup" }).to be_truthy
      end
    end
  end

  context 'When shared record set is CRL' do
    it '(UNC) record is assigned to UNC, Duke, NCSU' do
      rec = make_rec
      rec << MARC::DataField.new('773', '0', ' ',
                                 ['t', 'Center for Research Libraries (CRL) eResources (online collection)'])
      result = run_traject_on_record('unc', rec)['institution']
      expect(result).to eq(
                          ['unc', 'duke', 'ncsu']
                        )
    end

    it '(UNC) record_data_source includes "Shared Records" and "CRL"' do
      rec = make_rec
      rec << MARC::DataField.new('773', '0', ' ',
                                 ['t', 'Center for Research Libraries (CRL) eResources (online collection)'])
      result = run_traject_on_record('unc', rec)['record_data_source']
      expect(result).to eq(
                          ['ILSMARC', 'Shared Records', 'CRL']
                        )
    end

    it '(UNC) virtual_collection includes "TRLN Shared Records. Center for Research Libraries (CRL) e-resources."' do
      rec = make_rec
      rec << MARC::DataField.new('773', '0', ' ',
                                 ['t', 'Center for Research Libraries (CRL) eResources (online collection)'])
      result = run_traject_on_record('unc', rec)['virtual_collection']
      expect(result).to eq(
                          ['TRLN Shared Records. Center for Research Libraries (CRL) e-resources.']
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
                          "{\"href\":\"http://purl.access.gpo.gov/GPO/LPS32255\",\"type\":\"fulltext\",\"note\":\"Spanish\",\"restricted\":\"false\"}"
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
end
