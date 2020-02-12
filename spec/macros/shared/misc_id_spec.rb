# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::Shared::MiscId do
  include Util::TrajectRunTest
  let(:misc_id) { run_traject_json('duke', 'misc_id', 'mrc') }
  let(:misc_id01) { run_traject_json('unc', 'ids01') }
  let(:misc_id02) { run_traject_json('unc', 'misc_id_028_missing_a', 'mrc') }
  let(:misc_id03) { run_traject_json('unc', 'misc_id_upc', 'mrc') }
  let(:misc_id_010) { run_traject_json('unc', 'misc_id_010', 'mrc') }
  let(:misc_id_015) { run_traject_json('unc', 'misc_id_015', 'mrc') }
  let(:misc_id_024) { run_traject_json('unc', 'misc_id_024', 'mrc') }
  
  it '(MTA) sets misc_id' do
    result = misc_id['misc_id']
    expect(result).to eq(
      [{'value' => '86752311',
        'type' => 'LCCN'},
       {'value' => '13947215',
        'type' => 'NUCMC'},
       {'value' => '70001437 //r84',
        'type' => 'LCCN'},
       {'value' => '77373485',
        'type' => 'LCCN (canceled or invalid)'},
       {'value' => 'GB96-439',
        'type' => 'National Bibliography Number'},
       {'value' => 'GB7205212',
        'type' => 'British national bibliography',
        'qual' => 'v. 2'},
       {'value' => '20023012390',
        'type' => 'National Bibliography Number',
        'qual' => 'pbk.'},
       {'value' => 'BBM68-3648',
        'type' => 'National Bibliography Number'},
       {'value' => 'LACAP68-3222',
        'type' => 'National Bibliography Number'},
       {'value' => 'M011406601',
        'type' => 'International Standard Music Number'},
       {'value' => 'M011406605',
        'type' => 'International Standard Music Number',
        'qual' => 'bananas'},
       {'value' => 'M500246596',
        'type' => 'Canadian Geographical Names Database',
        'qual' => 'sewn'},
       {'value' => 'M001124089',
        'type' => 'International Standard Music Number'},
       {'value' => 'M001124083',
        'type' => 'International Standard Music Number (canceled or invalid)'},
       {'value' => 'alfredelizabethbrandcolcivilwarleefamily',
        'type' => 'Unspecified Standard Number',
        'qual' => 'DUKEPLEAD'},
       {'value' => 'EDO-CE-00-222',
        'type' => 'Technical Report Number'},
       {'value' => 'EDO-CE-00-333',
        'type' => 'Technical Report Number (canceled or invalid)'},
       {'value' => 'MAG100',
        'display' => 'false'},
       {'value' => 'MAG100',
        'type' => 'Video Publisher Number',
        'qual' => 'Criterion Collection'},
       {'value' => 'PASPFZ',
        'type' => 'CODEN designation'},
       {'value' => '1023-A',
        'type' => 'GPO Item Number',
        'qual' => 'online'},
       {'value' => '1023-B',
        'type' => 'GPO Item Number',
        'qual' => 'microfiche'},
       {'value' => 'Serial no. 107-25 (United States. Congress. House. Committee on Financial Services)',
        'type' => 'Report Number'},
        {"display"=>"false", "value"=>"3047014"},
        {"display"=>"false", "value"=>"003047014"}]
    )
  end

    it '(MTA) sets LCCN' do
    result = misc_id01['misc_id'][0]
    expect(result).to eq(
                        {'value' => 'sn 78003579', 'type' => 'LCCN'}
                      )
    end

    it '(MTA) sets NUCMC' do
      result = misc_id01['misc_id'][2]
      expect(result).to eq(
                          {'value' => 'ms 69001649', 'type' => 'NUCMC'}
                        )
    end

    it '(MTA) sets misc_id from multiple 010 subfields' do
      #=010  \\$a   123$bnuc123$z666
      result = misc_id_010['misc_id']
      expect(result).to eq([
                             {'value' => '123', 'type' => 'LCCN'},
                             {'value' => 'nuc123', 'type' => 'NUCMC'},
                             {'value' => '666', 'type' => 'LCCN (canceled or invalid)'},
                           ]
                        )
    end


    it '(MTA) sets misc_id from 015' do
      result = misc_id_015['misc_id']
      #=015  \\$a123 (a)$qb$a234$q(c)$z666 (d)$qf$z777$q(e)$2can 
      expect(result).to eq([
                             {'value' => '123',
                              'qual' => 'a; b',
                              'type' => 'Canadiana'},
                             {'value' => '234',
                              'qual' => 'c',
                              'type' => 'Canadiana'},
                             {'value' => '666',
                              'qual' => 'd; f',
                              'type' => 'Canadiana (canceled or invalid)'},
                             {'value' => '777',
                              'qual' => 'e',
                              'type' => 'Canadiana (canceled or invalid)'},
                           ]
                        )
    end

    it '(MTA) sets National Bib Number with type lookup' do
      result = misc_id01['misc_id'][4]
      expect(result).to eq(
                          {'value' => '123', 'qual' => 'v. 1', 'type' => "Bibliografía d'Andorra"}
                        )
    end

    it '(MTA) sets National Bib Number without type lookup' do
      result = [ misc_id01['misc_id'][5], misc_id01['misc_id'][6], misc_id01['misc_id'][7] ]
      expect(result).to eq([
                             {'value' => '123', 'qual' => 'v. 1', 'type' => "National Bibliography Number"},
                             {'value' => '789', 'qual' => 'v. 2', 'type' => "National Bibliography Number"},
                             {'value' => '1010', 'type' => "National Bibliography Number"}
                           ])
    end

    it '(MTA) sets National Bib Number with no qual when entire $a value in parens' do
      result = misc_id01['misc_id'][8]
      expect(result).to eq(
                          {'value' => '(USSR 68-VKP)', 'type' => "National Bibliography Number"}
                        )
    end

#    =024  08$a111 (orig)$q(home)$z222$2amnbo
    it '(MTA) sets misc_id from 024' do
      result = misc_id_024['misc_id']
      expect(result).to eq([
                             {'value' => '111',
                              'type' => "American National Biography Online",
                              'qual' => 'orig; home'
                             },
                             {'value' => '222',
                              'type' => "American National Biography Online (canceled or invalid)"}
                           ]
                        )
    end

    
    it '(MTA) skips setting misc_id from 028 if no $a present' do
    result = misc_id02['misc_id']
    expect(result).to eq(
                        [{'value' => 'E3VB-0629-1',
                          'type' => 'Matrix Number'},
                         {'value' => 'E3VB-0630-1',
                          'type' => 'Matrix Number'},
                         {'value' => '123',
                          'qual' => 'a; b',
                          'type' => 'Unspecified Standard Number'},
                         {'value' => '234',
                          'qual' => 'a; b',
                          'type' => 'Unspecified Standard Number'}
                        ]
                      )
    end

    it '(MTA) does not set UPC as misc_id' do
      result = misc_id03['misc_id']
      upcentry = {"value"=>"034571173412"}
      expect(result).not_to include(upcentry)
    end
end
