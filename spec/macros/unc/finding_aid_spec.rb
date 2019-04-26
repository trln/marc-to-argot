# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::UNC::FindingAid

describe MarcToArgot::Macros::UNC::FindingAid do
  include Util::TrajectRunTest

  describe 'collection_or_subunit?' do
    it '(UNC) returns true if LDR/07 = c or d' do
      rec = make_rec
      rec.leader[7] = 'c'
      expect(collection_or_subunit?(rec)).to eq(true)

      rec2 = make_rec
      rec2.leader[7] = 'd'
      expect(collection_or_subunit?(rec2)).to eq(true)
    end
  end

  describe 'has_finding_aid_url?' do
    it '(UNC) returns true if 856 42 with finding aid url' do
      rec = make_rec
      rec << MARC::DataField.new('856', '4', '2',
                                 ['u', 'http://finding-aids.lib.unc.edu/03287/'])
      expect(has_finding_aid_url?(rec)).to eq(true)
    end
    it '(UNC) returns false if no finding aid url' do
      rec = make_rec
      rec << MARC::DataField.new('856', '4', '2',
                                 ['u', 'http://library.unc.edu'])
      expect(has_finding_aid_url?(rec)).to be_nil
    end
  end
  
  describe 'has_nps_id?' do
    it '(UNC) returns true if 919 0. where $a starts with nps' do
      rec = make_rec
      rec << MARC::DataField.new('919', '0', ' ',
                                 ['a', 'nps3605088x'])
      expect(has_nps_id?(rec)).to eq(true)
    end
    it '(UNC) returns false if no nps id' do
      rec = make_rec
      rec << MARC::DataField.new('919', '0', ' ',
                                 ['a', 'something else'])
      expect(has_nps_id?(rec)).to be_nil
    end
  end

  describe 'finding_aid_enhanceable?' do
    context 'WHEN record has 856 42 with $u matching http://finding-aids.lib.unc.edu/' do
      context 'AND LDR/07 = d' do
        it '(UNC) finding_aid_enhanceable? = ead' do
          rec = make_rec
          rec.leader[7] = 'd'
          rec << MARC::DataField.new('856', '4', '2',
                                     ['3', 'Finding aid'],
                                     ['u', 'http://finding-aids.lib.unc.edu/03287/'])
          result = finding_aid_enhanceable?(rec)
          expect(result).to eq('ead')
        end
      end
      context 'AND LDR/07 = c' do
        it '(UNC) finding_aid_enhanceable? = ead' do
          rec = make_rec
          rec.leader[7] = 'c'
          rec << MARC::DataField.new('856', '4', '2',
                                     ['3', 'Finding aid'],
                                     ['u', 'http://finding-aids.lib.unc.edu/03287/'])
          result = finding_aid_enhanceable?(rec)
          expect(result).to eq('ead')
        end
      end
      context 'AND LDR/07 is not c or d' do
        it '(UNC) finding_aid_enhanceable? = nil' do
          rec = make_rec
          rec.leader[7] = 'm'
          rec << MARC::DataField.new('856', '4', '2',
                                     ['3', 'Finding aid'],
                                     ['u', 'http://finding-aids.lib.unc.edu/03287/'])
          result = finding_aid_enhanceable?(rec)
          expect(result).to be_nil
        end
      end
    end

    context 'WHEN record has nps id in 919' do
      it '(UNC) finding_aid_enhanceable? = nps' do
        rec = make_rec
        rec << MARC::DataField.new('919', '0', ' ',
                                   ['a', 'nps666'])
        result = finding_aid_enhanceable?(rec)
        expect(result).to eq('nps')
      end
    end

    context 'WHEN record does not have finding aid url or nps id' do
      it '(UNC) finding_aid_enhanceable? = nil' do
        rec = make_rec
        result = finding_aid_enhanceable?(rec)
        expect(result).to be_nil
      end
    end
  end

  describe 'get_finding_aid_id' do
    it '(UNC) gets EAD id from url for real finding aids' do
      rec = make_rec
      rec << MARC::DataField.new('856', '4', '2',
                                 ['u', 'http://finding-aids.lib.unc.edu/03287/'])
      expect(get_finding_aid_id(rec)).to eq('03287')
    end
  end

  describe 'get_nps_id' do
    it '(UNC) gets EAD id from url for NPS titles' do
      rec = make_rec
      rec << MARC::DataField.new('919', '0', ' ',
                                 ['a', 'nps36049712'])
      expect(get_nps_id(rec)).to eq('nps36049712')
    end
  end

  describe 'get_finding_aid_urls' do
    it '(UNC) gets finding aid urls' do
      rec = make_rec
      rec << MARC::DataField.new('856', '4', '2',
                                 ['u', 'http://finding-aids.lib.unc.edu/03287/'])
      rec << MARC::DataField.new('856', '4', '2',
                                 ['u', 'http://finding-aids.lib.unc.edu/PN2020.D92/'])
      arr = ['https://finding-aids.lib.unc.edu/03287/',
             'https://finding-aids.lib.unc.edu/PN2020.D92/']
      expect(get_finding_aid_urls(rec)).to eq(arr)
    end
  end

  describe 'get_ead_uri' do
    it '(UNC) builds URI to EAD XML file from EAD or NPS ID' do
      uri = 'https://finding-aids.lib.unc.edu/ead/03287.xml'
      expect(get_ead_uri('03287')).to eq(uri)
    end
  end

  describe 'get_ead' do
    it '(UNC) gets EAD XML file for ID' do
      ead = get_ead('03287')
      expect(ead).to be_a Nokogiri::XML::Document
    end
  end
end
