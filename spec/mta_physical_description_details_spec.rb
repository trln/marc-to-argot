# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:details340) { run_traject_json('unc', 'phys_desc_details_340', 'mrc') }  

  xit '(MTA) sets physical_description_details from 340' do
    result = details340['physical_description_details']
    expect(result).to eq(
                        [
                          {'label' => 'Shell pin: Base/substrate material',
                           'value' => 'wood'},
                          {'label' => 'Shell pin: Dimensions',
                           'value' => '3 x 4 cm'},
                          {'label' => 'Shell pin: Technique',
                           'value' => 'carved'},
                          {'label' => 'Base/substrate material',
                           'value' => 'vinyl; plastic'},
                          {'label' => 'Dimensions',
                           'value' => '35 x 23 x 13 cm'},
                          {'label' => 'Medium',
                           'value' => 'paint'},
                          {'label' => 'Support material',
                           'value' => 'wood'},
                          {'label' => 'Base/substrate material',
                           'value' => 'plastic; metal'},
                          {'label' => 'Dimensions',
                           'value' => '4 3/4 in.'},
                          {'label' => 'Production rate/ratio',
                           'value' => '1.4 m/s'},
                          {'label' => 'Color characteristics',
                           'value' => 'polychrome; black and white'},
                          {'label' => 'Found in/on',
                           'value' => 'front cover pocket'},
                          {'label' => 'Generation of reproduction',
                           'value' => 'original'},
                          {'label' => 'Base/substrate material',
                           'value' => 'paper tape'},
                          {'label' => 'Technique',
                           'value' => 'punched'},
                          {'label' => 'Use requires',
                           'value' => 'Ibord Model 74 tape reader'},
                          {'label' => 'Base/substrate material',
                           'value' => 'paper'},
                          {'label' => 'Technique',
                           'value' => 'printed'},
                          {'label' => 'Layout',
                           'value' => 'double sided; vertical score'},
                          {'label' => 'Book format',
                           'value' => 'folio'},
                          {'label' => 'Font size',
                           'value' => 'large print'},
                          {'label' => 'Base/substrate material',
                           'value' => 'acetate'},
                          {'label' => 'Polarity',
                           'value' => 'negative'}
                        ]
                      )
    end
end




