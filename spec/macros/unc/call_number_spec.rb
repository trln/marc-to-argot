# coding: utf-8

require 'spec_helper'
include MarcToArgot::Macros::UNC::CallNumber

describe MarcToArgot::Macros::UNC::CallNumber do
  include Util::TrajectRunTest

  context 'WHEN no call number data present' do
    it '(UNC) proceeds gracefully' do
      rec = make_rec
      result = run_traject_on_record('unc', rec)
      expect(result['call_number_schemes']).to be_nil
      expect(result['shelfkey']).to be_nil
      expect(result['reverse_shelfkey']).to be_nil
      expect(result['lcc_callnum_classification']).to be_nil
      expect(result['lc_call_nos_normed']).to be_nil
      expect(result['shelf_numbers']).to be_nil
    end
  end

  it '(UNC) extracts call numbers from items' do
    rec = make_rec
    rec << MARC::DataField.new('999', '9', '1',
                               ['i', 'i1688265'],
                               ['p', '0501#'],
                               ['q', '|aML96.4 .B3'])
    rec << MARC::DataField.new('999', '9', '1',
                               ['i', 'i1688265'],
                               ['p', '099#9'],
                               ['q', '|aCD-1234'])
    result = run_traject_on_record('unc', rec)['call_number_schemes']
    expect(result).to eq(['LC', 'ALPHANUM'])
  end

  it '(UNC) extracts LC call numbers from the bib' do
    rec = make_rec
    rec << MARC::DataField.new('050', ' ', ' ',
                               ['a', 'HV9468.G75'],
                               ['b', 'R33 2017'])
    result = run_traject_on_record('unc', rec)['call_number_schemes']
    expect(result).to include('LC')
  end

  it '(UNC) extracts SUDOC call numbers from the bib' do
    rec = make_rec
    rec << MARC::DataField.new('086', '0', ' ',
                               ['a', 'A 101.2:AN 5/5/983'])
    result = run_traject_on_record('unc', rec)['call_number_schemes']
    expect(result).to include('SUDOC')
  end

  it '(UNC) sets call_number_schemes from all call numbers' do
    rec = make_rec
    rec << MARC::DataField.new('999', '9', '1',
                               ['i', 'i1688265'],
                               ['p', '0501#'],
                               ['q', '|aML96.4 .B3'])
    rec << MARC::DataField.new('999', '9', '1',
                               ['i', 'i1688265'],
                               ['p', '099#9'],
                               ['q', '|aCD-1234'])
    rec << MARC::DataField.new('086', '0', ' ',
                               ['a', 'A 101.2:AN 5/5/983'])
    result = run_traject_on_record('unc', rec)['call_number_schemes']
    expect(result).to eq(%w[LC ALPHANUM SUDOC])
  end

  it '(UNC) sets lcc_callnum_classification from all LC numbers' do
    rec = make_rec
    rec << MARC::DataField.new('999', '9', '1',
                               ['i', 'i1688265'],
                               ['p', '0501#'],
                               ['q', '|aML96.4 .B3'])
    rec << MARC::DataField.new('050', ' ', ' ',
                               ['a', 'HV9468.G75'],
                               ['b', 'R33 2017'])
    rec << MARC::DataField.new('086', '0', ' ',
                               ['a', 'A 101.2:AN 5/5/983'])
    result = run_traject_on_record('unc', rec)
    expect(result['lcc_callnum_classification'].sort).to eq(
      [
        'H - Social sciences',
        'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology',
        'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology|HV7231 - HV9960 Criminal justice administration',
        'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology|HV7231 - HV9960 Criminal justice administration|HV8301 - HV9920.7 Penology. Prisons. Corrections',
        'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology|HV7231 - HV9960 Criminal justice administration|HV8301 - HV9920.7 Penology. Prisons. Corrections|HV9441 - HV9920.7 By region or country',
        'M - Music',
        'M - Music|ML1 - ML3930 Literature on music',
        'M - Music|ML1 - ML3930 Literature on music|ML93 - ML96.5 Manuscripts, autographs, etc.'
      ]
    )
  end

  describe 'setting shelfkey (and reverse) values' do
    it '(UNC) uses first LC call number to set shelfkey (and reverse) values' do
      rec = make_rec
      rec << MARC::DataField.new('999', '9', '1',
                                 ['i', 'i1688265'],
                                 ['p', '0501#'],
                                 ['q', '|aML96.4 .B3'])
      rec << MARC::DataField.new('999', '9', '1',
                                 ['i', 'i1688265'],
                                 ['p', '0501#'],
                                 ['q', '|aHV9468.G75 R33 2017'])
      rec << MARC::DataField.new('050', ' ', ' ',
                                 ['a', 'HV9468.G75'],
                                 ['b', 'R33 2017'])
      result = run_traject_on_record('unc', rec)
      expect(result['shelfkey']).to eq('lc:ML.00964.B3')
      expect(result['reverse_shelfkey']).to eq('lc:DE}ZZQTV}OW')
    end

    it '(UNC) but shelfkey prefers item call numbers over bib call numbers' do
      rec = make_rec
      rec << MARC::DataField.new('050', ' ', ' ',
                                 ['a', 'HV9468.G75'],
                                 ['b', 'R33 2017'])
      rec << MARC::DataField.new('999', '9', '1',
                                 ['i', 'i1688265'],
                                 ['p', '0501#'],
                                 ['q', '|aML96.4 .B3'])
      result = run_traject_on_record('unc', rec)
      expect(result['shelfkey']).to eq('lc:ML.00964.B3')
      expect(result['reverse_shelfkey']).to eq('lc:DE}ZZQTV}OW')
    end
  end

  describe 'setting fields for call number searching' do
    let(:result) do
      rec = make_rec
      rec << MARC::DataField.new('999', '9', '1',
                                 ['i', 'i1688265'],
                                 ['p', '0501#'],
                                 ['q', '|aML96.4 .B3'],
                                 ['v', 'Bd.1'])
      rec << MARC::DataField.new('999', '9', '1',
                                 ['i', 'i1688265'],
                                 ['p', '0501#'],
                                 ['q', '|aHV9468.G75|bR33 2017'],
                                 ['v', 'Bd.2'])
      rec << MARC::DataField.new('999', '9', '1',
                                 ['i', 'i1688265'],
                                 ['p', '099#9'],
                                 ['q', '|aCD-1234'],
                                 ['v', 'Bd.1'])
      rec << MARC::DataField.new('999', '9', '1',
                                 ['i', 'i1688265'],
                                 ['p', '099#9'],
                                 ['q', '|aCD-5678'],
                                 ['v', 'Bd.1'])
      rec << MARC::DataField.new('050', ' ', ' ',
                                 ['a', 'HV9468.G75'],
                                 ['b', 'R33 2017'])
      rec << MARC::DataField.new('090', ' ', ' ',
                                 ['a', 'ML96.4'],
                                 ['b', '.B3'],
                                 ['a', 'HV9468.G75'])
      run_traject_on_record('unc', rec)
    end

    it '(UNC) sets shelf_numbers from all ALPHANUM call numbers' do
      expect(result['shelf_numbers']).to eq(['CD-1234', 'CD-5678'])
    end

    it '(UNC) sets lc_call_nos_normed from all LC numbers' do
      expect(result['lc_call_nos_normed']).to eq(
        ['ML.00964.B3', 'HV.9468.G75.R33--2017', 'HV.9468.G75.B3']
      )
    end
  end
end
