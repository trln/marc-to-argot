# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::Shared::MiscId do
  include Util::TrajectRunTest
  let(:misc_id) { run_traject_json('duke', 'misc_id', 'mrc') }
  let(:misc_id01) { run_traject_json('unc', 'ids01') }
  let(:misc_id02) { run_traject_json('unc', 'misc_id_028_missing_a', 'mrc') }
  
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
       {'value' => 'alfredelizabethbrandcolcivilwarleefamily DUKEPLEAD',
        'type' => 'Unspecified Standard Number'},
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
        'type' => 'Report Number'}]
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

    it '(MTA) skips setting misc_id from 028 if no $a present' do
    result = misc_id02['misc_id']
    expect(result).to eq(
                        [{'value' => 'E3VB-0629-1',
                          'type' => 'Matrix Number'},
                         {'value' => 'E3VB-0630-1',
                          'type' => 'Matrix Number'}
                        ]
                      )
  end
end
