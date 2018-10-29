# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::Shared::PhysicalMedia do
  include Util::TrajectRunTest
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

  it '(MTA) Sets physical_media to Online if access_type includes Online' do
    result = at01['physical_media']
    expect(result).to eq(['Online'])

    result = at02['physical_media']
    expect(result).to include('Online')

  end
end
