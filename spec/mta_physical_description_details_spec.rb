# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:details340) { run_traject_json('unc', 'phys_desc_details_340', 'mrc') }  
  let(:details344) { run_traject_json('unc', 'phys_desc_details_344', 'mrc') }
  let(:details345) { run_traject_json('unc', 'phys_desc_details_345', 'mrc') }
  let(:details346) { run_traject_json('unc', 'phys_desc_details_346', 'mrc') }
  let(:details347) { run_traject_json('unc', 'phys_desc_details_347', 'mrc') }
  let(:details352) { run_traject_json('unc', 'phys_desc_details_352', 'mrc') }
  
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

  xit '(MTA) sets physical_description_details from 344' do
    result = details344['physical_description_details']
    expect(result).to eq(
                        [
                          {'label' => 'Recording type',
                           'value' => 'analog'},
                          {'label' => 'Speed',
                           'value' => '1 7/8 ips'},
                          {'label' => 'Tape type',
                           'value' => '4 track'},
                          {'label' => 'Recording type',
                           'value' => 'analog'},
                          {'label' => 'Recording medium',
                           'value' => 'magnetic'},
                          {'label' => 'Channels',
                           'value' => 'stereo; surround'},
                          {'label' => 'Special audio characteristics',
                           'value' => 'Dolby-B encoded'},
                          {'label' => 'Recording type',
                           'value' => 'analog'},
                          {'label' => 'Speed',
                           'value' => '78 rpm'},
                          {'label' => 'Groove',
                           'value' => 'coarse groove'},
                          {'label' => 'Sound track configuration',
                           'value' => 'edge track'}
                        ]
                      )
  end

  xit '(MTA) sets physical_description_details from 345' do
    result = details345['physical_description_details']
    expect(result).to eq(
                        [
                          {'label' => 'DVD: Presentation format',
                           'value' => 'full screen (1.33:1)'},
                          {'label' => 'DVD: Projection speed',
                           'value' => '24 fps'}
                        ]
                      )
  end

  xit '(MTA) sets physical_description_details from 346' do
    result = details346['physical_description_details']
    expect(result).to eq(
                        [
                          {'label' => 'Video format',
                           'value' => 'VHS'},
                          {'label' => 'Broadcast standard',
                           'value' => 'NTSC'}
                        ]
                      )
  end

  xit '(MTA) sets physical_description_details from 347' do
    result = details347['physical_description_details']
    expect(result).to eq(
                        [
                          {'label' => 'File type',
                           'value' => 'video file'},
                          {'label' => 'File format',
                           'value' => 'DVD video'},
                          {'label' => 'Regional encoding',
                           'value' => 'all regions'},
                          {'label' => 'File type',
                           'value' => 'image file'},
                          {'label' => 'File format',
                           'value' => 'JPEG'},
                          {'label' => 'Image resolution',
                           'value' => '3.1 megapixels'},
                          {'label' => 'Image size',
                           'value' => '1.5 MB'},
                          {'label' => 'File type',
                           'value' => 'audio file'},
                          {'label' => 'File format',
                           'value' => 'MP3'},
                          {'label' => 'Bitrate',
                           'value' => '128 kbps'}
                        ]
                      )
  end
  
  xit '(MTA) sets physical_description_details from 352' do
    result = details352['physical_description_details']
    expect(result).to eq(
                        [
                          {'label' => 'Data set graphics details',
                           'value' => 'Raster : Grid cell (20,880 x 43,200)'}
                        ]
                      )
  end

end
