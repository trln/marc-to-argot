# coding: utf-8
require 'spec_helper'
describe MarcToArgot::Macros::Shared::ResourceType do
  include Util::TrajectRunTest
  let(:resource_type_01) { run_traject_json('duke', 'resource_type_01', 'mrc') }
  let(:resource_type_02) { run_traject_json('duke', 'resource_type_02', 'mrc') }
  let(:resource_type_03) { run_traject_json('duke', 'resource_type_03', 'mrc') }
  let(:resource_type_04) { run_traject_json('duke', 'resource_type_04', 'mrc') }
  let(:resource_type_05) { run_traject_json('duke', 'resource_type_05', 'mrc') }
  let(:resource_type_06) { run_traject_json('duke', 'resource_type_06', 'mrc') }
  let(:resource_type_07) { run_traject_json('duke', 'resource_type_07', 'mrc') }
  let(:resource_type_08) { run_traject_json('duke', 'resource_type_08', 'mrc') }
  let(:resource_type_09) { run_traject_json('duke', 'resource_type_09', 'mrc') }
  let(:resource_type_10) { run_traject_json('duke', 'resource_type_10', 'mrc') }
  let(:resource_type_11) { run_traject_json('duke', 'resource_type_11', 'mrc') }
  let(:resource_type_12) { run_traject_json('duke', 'resource_type_12', 'mrc') }
  let(:resource_type_13) { run_traject_json('duke', 'resource_type_13', 'mrc') }
  let(:resource_type_14) { run_traject_json('duke', 'resource_type_14', 'mrc') }
  let(:resource_type_15) { run_traject_json('duke', 'resource_type_15', 'mrc') }
  let(:resource_type_16) { run_traject_json('duke', 'resource_type_16', 'mrc') }
  let(:resource_type_17) { run_traject_json('duke', 'resource_type_17', 'mrc') }
  let(:resource_type_18) { run_traject_json('duke', 'resource_type_18', 'mrc') }
  let(:resource_type_19) { run_traject_json('duke', 'resource_type_19', 'mrc') }
  let(:resource_type_20) { run_traject_json('unc', 'resource_type_20', 'xml') }
  let(:resource_type_21) { run_traject_json('unc', 'resource_type_21', 'xml') }
  let(:resource_type_22) { run_traject_json('unc', 'resource_type_22', 'mrc') }
  let(:resource_type_23) { run_traject_json('unc', 'resource_type_23', 'mrc') }
  let(:resource_type_24) { run_traject_json('unc', 'resource_type_24', 'mrc') }
  let(:resource_type_25) { run_traject_json('unc', 'resource_type_25', 'mrc') }
  
  it '(Duke) Sets resource_type to Music score' do
    result = resource_type_01['resource_type']
    expect(result).to include('Music score')
  end

  it '(Duke) Sets resource_type to Journal, Magazine, or Periodical' do
    result = resource_type_02['resource_type']
    expect(result).to include('Journal, Magazine, or Periodical')
  end

  it '(Duke) Sets resource_type to Newspaper' do
    result = resource_type_03['resource_type']
    expect(result).to include('Newspaper')
  end

  it '(Duke) Sets resource_type to Book' do
    result = resource_type_04['resource_type']
    expect(result).to include('Book')
  end

  it '(Duke) Sets resource_type to Archival and manuscript material' do
    result = resource_type_06['resource_type']
    expect(result).to include('Music recording')
  end

  it '(Duke) Sets resource_type to Video' do
    result = resource_type_07['resource_type']
    expect(result).to include('Video')
  end

  it '(Duke) Sets resource_type to Map' do
    result = resource_type_08['resource_type']
    expect(result).to include('Map')
  end

  it '(Duke) Sets resource_type to Government publication' do
    result = resource_type_09['resource_type']
    expect(result).to include('Government publication')
  end

  it '(MTA) Does not set gov pub value if 260 or 264 includes university' do
    result = resource_type_23['resource_type']
    expect(result).to_not include('Government publication')
  end

  it 'Does not set gov pub value if 260 or 264 includes "school of"' do
    result = resource_type_25['resource_type']
    expect(result).to_not include('Government publication')
  end
  
  it '(MTA) Does not croak checking resource_type if there is no 260 or 264' do
    result = resource_type_24['resource_type']
    expect(result).to include('Government publication')
  end

  it '(Duke) Sets resource_type to Software/multimedia' do
    result = resource_type_10['resource_type']
    expect(result).to include('Software/multimedia')
  end

  it '(Duke) Sets resource_type to Web page or site' do
    result = resource_type_11['resource_type']
    expect(result).to include('Web page or site')
  end

  it '(Duke) Sets resource_type to Database' do
    result = resource_type_12['resource_type']
    expect(result).to include('Database')
  end

  it '(Duke) Sets resource_type to Dataset -- Statistical' do
    result = resource_type_13['resource_type']
    expect(result).to include('Dataset -- Statistical')
  end

  it '(Duke) Sets resource_type to Kit' do
    result = resource_type_14['resource_type']
    expect(result).to include('Kit')
  end

  it '(Duke) Sets resource_type to Non-musical sound recording' do
    result = resource_type_15['resource_type']
    expect(result).to include('Non-musical sound recording')
  end

  it '(Duke) Sets resource_type to Audiobook' do
    result = resource_type_16['resource_type']
    expect(result).to include('Audiobook')
  end

  it '(Duke) Sets resource_type to Image' do
    result = resource_type_17['resource_type']
    expect(result).to include('Image')
  end

  it '(Duke) Sets resource_type to Thesis/Dissertation' do
    result = resource_type_18['resource_type']
    expect(result).to include('Thesis/Dissertation')
  end

  it '(Duke) Sets resource_type to Object' do
    result = resource_type_19['resource_type']
    expect(result).to include('Object')
  end

  it '(UNC) Sets resource_type to Music recording only (not government publication)' do
    result = resource_type_20['resource_type']
    expect(result).to eq(['Music recording'])
  end

  it '(UNC) Sets resource_type to include Video AND Kit' do
    result = resource_type_21['resource_type']
    expect(result).to include('Video') && include('Kit')
  end
    
  context '006/00 = m' do
    context '006/09 = c' do
      it '(UNC) does NOT set as Image' do
        a = resource_type_22['resource_type']
        expect(a).to_not include('Image')
      end
    end
  end

  context 'LDR/06 = g' do
    context '008/33 = v' do
      it '(UNC) sets as Video' do
        a = resource_type_22['resource_type']
        expect(a).to include('Video')
      end
    end
  end

end
