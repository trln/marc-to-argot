# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::Shared::Notes do
  include Util::TrajectRunTest
  let(:misc_id) { run_traject_json('duke', 'misc_id', 'mrc') }

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
end
