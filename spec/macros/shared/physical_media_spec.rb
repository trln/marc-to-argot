# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::Shared::PhysicalMedia do
  include Util::TrajectRunTest

  it '(MTA) Sets physical_media to CD-ROM' do
    rec = make_rec
    rec << MARC::ControlField.new('007', 'co mg ---|||||')
    argot = run_traject_on_record('unc', rec)
    expect(argot['physical_media']).to eq(['CD-ROM'])
  end

  it '(MTA) Sets physical_media as expected' do
    rec = make_rec
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', '374 p'))
    pm1 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm1).to eq(['Print'])

    rec = make_rec
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', '374 p :'))
    pm2 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm2).to eq(['Print'])

    rec = make_rec
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', '192 p;'))
    pm3 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm3).to eq(['Print'])

    rec = make_rec
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', 'v ;'))
    pm4 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm4).to eq(['Print'])

    rec = make_rec
    rec.leader[5] = 'c'
    rec.leader[6] = 'a'
    rec.leader[7] = 's'
    rec << MARC::ControlField.new('008', '880811d19uu1967mauar         0   a0eng d')
    rec << MARC::DataField.new('245', '1', '4',
                               ['a', 'The Harvard Forest and Harvard Black Rock Forest annual report'],
                               ['h', '[serial] /'],
                               ['c', 'Harvard University.']
                              )
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', 'v. ;'))
    pm4 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm4).to eq(['Print'])

    rec = make_rec
    rec.leader[5] = 'c'
    rec.leader[6] = 'a'
    rec.leader[7] = 's'
    rec << MARC::ControlField.new('008', '880324d19671970dcuar1   i   f0   a0eng u')
    rec << MARC::DataField.new('245', '0', '0',
                               ['a', 'Pacesetters in innovation'],
                               ['h', '[microfilm serial] /']
                              )
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', 'v. ;'))
    pm4 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm4).to eq(['Microform > Microfilm'])

    rec = make_rec
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', 'xviii, 233p,.'))
    pm5 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm5).to eq(['Print'])

    rec = make_rec
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', '1 print :'))
    pm6 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm6).to eq(['Print'])

    rec = make_rec
    rec << MARC::ControlField.new('007', 'kh b')
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', '2 photoprints :'))
    pm7 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm7).to eq(['Photograph/picture'])

    rec = make_rec
    rec << MARC::ControlField.new('007', 'hd af|---||||')
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', '6 microfilm reels ;'))
    pm8 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm8).to eq(['Microform', 'Microform > Microfilm'])

    # Where extent is recorded without unit, assume print
    rec = make_rec
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', '165 ;'))
    pm9 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm9).to eq(['Print'])

    rec = make_rec
    rec << MARC::ControlField.new('007', 'ta')
    pm10 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm10).to eq(['Print'])

    rec = make_rec
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', '6 discs. 12 in. 33 1/3 rpm. microgroove.'))
    pm11 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm11).to be_nil

    rec = make_rec
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', '[2],16,26,43,[1]p ;'))
    pm12 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm12).to eq(['Print'])

    rec = make_rec
    rec << MARC::ControlField.new('007', 'mr baaafun|||||||------')
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', '11 reels of 11 (ca. 9315 ft.) :'))
    pm13 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm13).to eq(['35 mm film'])

    rec = make_rec
    rec << MARC::ControlField.new('007', 'aj cznzn')
    rec << MARC::ControlField.new('007', 'cr cnu||||||||')
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', '1 electronic map :'))
    pm14 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm14).to be_nil # Online gets added outside the macro proper

    rec = make_rec
    rec << MARC::DataField.new('300', ' ', ' ',
                               MARC::Subfield.new('a', 'maps :'))
    pm15 = run_traject_on_record('unc', rec)['physical_media']
    expect(pm15).to eq(['Print'])

    
end

  let(:physical_media_35mm) { run_traject_json('duke', 'physical_media_35mm', 'mrc') }
  let(:physical_media_art) { run_traject_json('duke', 'physical_media_art', 'mrc') }
  let(:physical_media_audiocassette) { run_traject_json('duke', 'physical_media_audiocassette', 'mrc') }
  let(:physical_media_cd) { run_traject_json('duke', 'physical_media_cd', 'mrc') }
  let(:physical_media_chart) { run_traject_json('duke', 'physical_media_chart', 'mrc') }
  let(:physical_media_dvd) { run_traject_json('duke', 'physical_media_dvd', 'mrc') }
  let(:physical_media_flash_card) { run_traject_json('duke', 'physical_media_flash_card', 'mrc') }
  let(:physical_media_microfiche) { run_traject_json('duke', 'physical_media_microfiche', 'mrc') }
  let(:physical_media_microfilm) { run_traject_json('duke', 'physical_media_microfilm', 'mrc') }
  let(:physical_media_microopaque) { run_traject_json('duke', 'physical_media_microopaque', 'mrc') }
  let(:physical_media_record_10) { run_traject_json('duke', 'physical_media_record_10', 'mrc') }
  let(:physical_media_record_12) { run_traject_json('duke', 'physical_media_record_12', 'mrc') }
  let(:physical_media_record_07) { run_traject_json('duke', 'physical_media_record_07', 'mrc') }
  let(:physical_media_rsi_surface) { run_traject_json('duke', 'physical_media_rsi_surface', 'mrc') }
  let(:physical_media_umatic) { run_traject_json('duke', 'physical_media_umatic', 'mrc') }
  let(:physical_media_vhs) { run_traject_json('duke', 'physical_media_vhs', 'mrc') }
  let(:at01) { run_traject_json('unc', 'access_type01') }
  let(:at02) { run_traject_json('unc', 'access_type02') }
  let(:pm1) { run_traject_json('nccu', 'physical_media1') }
  let(:pm2) { run_traject_json('duke', 'url0', 'mrc') }
  let(:resource_type_archival) { run_traject_json('duke', 'resource_type_archival', 'xml')}
  let(:resource_type_archival_unc) { run_traject_json('unc', 'resource_type_archival', 'xml')}
  
  it '(MTA) Sets physical_media to 35 mm film' do
    result = physical_media_35mm['physical_media']
    expect(result).to eq(['35 mm film'])
  end

  it '(MTA) Sets physical_media to Art' do
    result = physical_media_art['physical_media']
    expect(result).to eq(['Art', 'Print'])
  end

  it '(MTA) Sets physical_media to Audiocassette tape, Print' do
    result = physical_media_audiocassette['physical_media']
    expect(result).to eq(['Audiocassette tape', 'Print'])
  end

  it '(MTA) Sets physical_media to CD' do
    result = physical_media_cd['physical_media']
    expect(result).to eq(['CD'])
  end

  it '(MTA) Sets physical_media to chart' do
    result = physical_media_chart['physical_media']
    expect(result).to eq(['Chart'])
  end

  it '(MTA) Sets physical_media to DVD' do
    result = physical_media_dvd['physical_media']
    expect(result).to eq(['DVD'])
  end

  it '(MTA) Sets physical_media to Flash card' do
    result = physical_media_flash_card['physical_media']
    expect(result).to eq(['Flash card'])
  end

  it '(MTA) Sets physical_media to Microform > Microfiche' do
    result = physical_media_microfiche['physical_media']
    expect(result).to eq(['Microform','Microform > Microfiche'])
  end

  it '(MTA) Sets physical_media to Microform > Microfilm' do
    result = physical_media_microfilm['physical_media']
    expect(result).to eq(['Microform','Microform > Microfilm'])
  end

  it '(MTA) Sets physical_media to Microform > Microopaque' do
    result = physical_media_microopaque['physical_media']
    expect(result).to eq(['Microform','Microform > Microopaque'])
  end

  it '(MTA) Sets physical_media to 7" record, 45 rpm record, etc.' do
    result = physical_media_record_07['physical_media']
    expect(result).to eq(['7" record', '45 rpm record', 'Vinyl record'])
  end

  it '(MTA) Sets physical_media to 10" record, 33 1/3 rpm record, etc.' do
    result = physical_media_record_10['physical_media']
    expect(result).to eq(['10" record', '33 1/3 rpm record', 'Vinyl record'])
  end

  it '(MTA) Sets physical_media to 12" record, 33 1/3 rpm record, etc.' do
    result = physical_media_record_12['physical_media']
    expect(result).to eq(['12" record', '33 1/3 rpm record', 'Vinyl record'])
  end

  it '(MTA) Sets physical_media to Remote-sensing image > Surface observing' do
    result = physical_media_rsi_surface['physical_media']
    expect(result).to eq(['Print', 'Remote-sensing image','Remote-sensing image > Surface observing'])
  end

  it '(MTA) Sets physical_media to Videocassette (U-matic)' do
    result = physical_media_umatic['physical_media']
    expect(result).to eq(['Videocassette (U-matic)'])
  end

  it '(MTA) Sets physical_media to Videocassette (VHS)' do
    result = physical_media_vhs['physical_media']
    expect(result).to eq(['Videocassette (VHS)'])
  end

  it '(MTA for UNC) Sets physical_media to Online if access_type includes Online' do
    result = at01['physical_media']
    expect(result).to eq(['Online'])

    result = at02['physical_media']
    expect(result).to include('Online')
  end

  it '(MTA for NCCU) Sets physical_media to Online if access_type includes Online' do
    result = pm1['physical_media']
    expect(result).to include('Online')
  end

  it '(MTA for DUKE) Sets physical_media to Online if access_type includes Online' do
    result = pm2['physical_media']
    expect(result).to include('Online')
  end

  it '(MTA) Does NOT set physical_media to Print if resource_type is Archival' do
    result = resource_type_archival.fetch('physical_media', [])
    expect(result).not_to include('Print')
  end

  it '(UNC) Does NOT set physical_media to Print if resource_type is Archival' do
    result = resource_type_archival_unc.fetch('physical_media', [])
    expect(result).not_to include('Print')
  end
  # Test for NCSU is in spec/macros/ncsu/physical_media_spec.rb
end
