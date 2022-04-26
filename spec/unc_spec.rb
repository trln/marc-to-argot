require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:cat_date) { run_traject_json('unc', 'cat_date') }
  let(:cat_date2) { run_traject_json('unc', 'cat_date2') }

  it '(UNC) does not set virtual collection from 919$a' do
    rec = make_rec
    rec << MARC::DataField.new('919', ' ', ' ',
                               ['a', 'testcoll']
                              )
    result = run_traject_on_record('unc', rec)['virtual_collection']
    expect(result).to be_nil
  end

  it '(UNC) sets virtual collection from 919$t' do
    rec = make_rec
    rec << MARC::DataField.new('919', ' ', ' ',
                               ['t', 'testcoll'],
                               ['t', 'another']
                              )
    result = run_traject_on_record('unc', rec)['virtual_collection']
    expect(result).to eq(['testcoll', 'another'])
  end

  it '(UNC) sets filmfinder virtual collection from filmfinder 919$a' do
    rec = make_rec
    rec << MARC::DataField.new('919', ' ', ' ', ['a', 'filmfinder'])
    result = run_traject_on_record('unc', rec)['virtual_collection']
    expect(result).to eq(['UNC MRC FilmFinder online and special materials'])
  end

  it '(UNC) sets correct record_data_source for NCDHC records' do
    ncdhc = run_traject_json('unc', 'ncdhc')
    expect(ncdhc['record_data_source']).to eq(['MARC', 'NCDHC'])
  end

  it '(UNC) sets date_cataloged' do
    expect(cat_date['date_cataloged']).to(
      eq(['2004-10-01T04:00:00Z'])
    )
  end

  it '(UNC) sets date_cataloged' do
    expect(cat_date2['date_cataloged']).to(
      eq(['2004-10-01T04:00:00Z'])
    )
  end
end
