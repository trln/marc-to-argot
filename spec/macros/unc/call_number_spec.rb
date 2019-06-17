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
    end
  end


    context 'different LC call numbers in two item records ' do
      it '(UNC) sets call_number_schemes to LC' do
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

        result = run_traject_on_record('unc', rec)['call_number_schemes']
        expect(result).to(
          eq(['LC'])
        )
      end
      it '(UNC) uses first occurring LC call number to set shelfkey (and reverse) values' do
        rec = make_rec
        rec << MARC::DataField.new('999', '9', '1',
                                   ['i', 'i1688265'],
                                   ['p', '0501#'],
                                   ['q', '|aML96.4|b.B3'],
                                   ['v', 'Bd.1'])

        rec << MARC::DataField.new('999', '9', '1',
                                   ['i', 'i1688265'],
                                   ['p', '0501#'],
                                   ['q', '|aHV9468.G75|bR33 2017'],
                                   ['v', 'Bd.2'])

        result = run_traject_on_record('unc', rec)
        expect(result['shelfkey']).to(
          eq('lc:ML.00964.B3')
        )
        expect(result['reverse_shelfkey']).to(
          eq('lc:DE}ZZQTV}OW')
        )
      end

      it '(UNC) sets lcc_callnum_classification from both LC numbers' do
        rec = make_rec
        rec << MARC::DataField.new('999', '9', '1',
                                   ['i', 'i1688265'],
                                   ['p', '0501#'],
                                   ['q', '|aML96.4|b.B3'],
                                   ['v', 'Bd.1'])

        rec << MARC::DataField.new('999', '9', '1',
                                   ['i', 'i1688265'],
                                   ['p', '0501#'],
                                   ['q', '|aHV9468.G75|bR33 2017'],
                                   ['v', 'Bd.2'])

        result = run_traject_on_record('unc', rec)['lcc_callnum_classification'].sort
        expect(result).to(
          eq([
               'H - Social sciences',
               'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology',
               'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology|HV7231 - HV9960 Criminal justice administration',
               'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology|HV7231 - HV9960 Criminal justice administration|HV8301 - HV9920.7 Penology. Prisons. Corrections',
               'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology|HV7231 - HV9960 Criminal justice administration|HV8301 - HV9920.7 Penology. Prisons. Corrections|HV9441 - HV9920.7 By region or country',
               'M - Music',
               'M - Music|ML1 - ML3930 Literature on music',
               'M - Music|ML1 - ML3930 Literature on music|ML93 - ML96.5 Manuscripts, autographs, etc.'
             ])
        )
      end
    end

    context 'no item having call number, but bib has LC call number in 050 or 090' do
      it '(UNC) sets call_number_schemes to LC' do
        rec = make_rec
        rec << MARC::DataField.new('050', ' ', ' ',
                                   ['a', 'ML96.4'],
                                   ['b', '.B3'])

        result = run_traject_on_record('unc', rec)['call_number_schemes']
        expect(result).to(
          eq(['LC'])
        )
      end
      it '(UNC) uses first occurring LC call number to set shelfkey (and reverse) values' do
        rec = make_rec
        rec << MARC::DataField.new('050', ' ', ' ',
                                   ['a', 'ML96.4'],
                                   ['b', '.B3'])
        rec << MARC::DataField.new('999', '9', '1',
                                   ['i', 'i1688265'],
                                   ['v', 'Bd.1'])
        result = run_traject_on_record('unc', rec)
        expect(result['shelfkey']).to(
          eq('lc:ML.00964.B3')
        )
        expect(result['reverse_shelfkey']).to(
          eq('lc:DE}ZZQTV}OW')
        )
      end

      it '(UNC) sets lcc_callnum_classification from both LC numbers' do
        rec = make_rec
        rec << MARC::DataField.new('090', ' ', ' ',
                                   ['a', 'HV9468.G75'],
                                   ['b', 'R33 2017'],
                                   ['a', 'ML96.4'])

        result = run_traject_on_record('unc', rec)['lcc_callnum_classification'].sort
        expect(result).to(
          eq([
               'H - Social sciences',
               'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology',
               'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology|HV7231 - HV9960 Criminal justice administration',
               'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology|HV7231 - HV9960 Criminal justice administration|HV8301 - HV9920.7 Penology. Prisons. Corrections',
               'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology|HV7231 - HV9960 Criminal justice administration|HV8301 - HV9920.7 Penology. Prisons. Corrections|HV9441 - HV9920.7 By region or country',
               'M - Music',
               'M - Music|ML1 - ML3930 Literature on music',
               'M - Music|ML1 - ML3930 Literature on music|ML93 - ML96.5 Manuscripts, autographs, etc.'
             ])
        )
      end
    end

    context 'item has call number and bib has call number' do
    it '(UNC) sets call_number_schemes to LC' do
        rec = make_rec
        rec << MARC::DataField.new('999', '9', '1',
                                   ['i', 'i1688265'],
                                   ['p', '0501#'],
                                   ['q', '|aML96.4|b.B3'],
                                   ['v', 'Bd.1'])

        rec << MARC::DataField.new('090', ' ', ' ',
                                   ['a', 'HV9468.G75'],
                                   ['b', 'R33 2017'])
        result = run_traject_on_record('unc', rec)['call_number_schemes']
        expect(result).to(
          eq(['LC'])
        )
    end

    it '(UNC) uses first occurring LC call number to set shelfkey (and reverse) values' do
        rec = make_rec
        rec << MARC::DataField.new('999', '9', '1',
                                   ['i', 'i1688265'],
                                   ['p', '0501#'],
                                   ['q', '|aML96.4|b.B3'],
                                   ['v', 'Bd.1'])

        rec << MARC::DataField.new('090', ' ', ' ',
                                   ['a', 'HV9468.G75'],
                                   ['b', 'R33 2017'])

        result = run_traject_on_record('unc', rec)
        expect(result['shelfkey']).to(
          eq('lc:ML.00964.B3')
        )
        expect(result['reverse_shelfkey']).to(
          eq('lc:DE}ZZQTV}OW')
        )
     end

     it '(UNC) sets lcc_callnum_classification from both LC numbers' do
        rec = make_rec
        rec << MARC::DataField.new('999', '9', '1',
                                   ['i', 'i1688265'],
                                   ['p', '0501#'],
                                   ['q', '|aML96.4|b.B3'],
                                   ['v', 'Bd.1'])

        rec << MARC::DataField.new('090', ' ', ' ',
                                   ['a', 'HV9468.G75'],
                                   ['b', 'R33 2017'])

        result = run_traject_on_record('unc', rec)['lcc_callnum_classification'].sort
        expect(result).to(
          eq([
               'H - Social sciences',
               'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology',
               'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology|HV7231 - HV9960 Criminal justice administration',
               'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology|HV7231 - HV9960 Criminal justice administration|HV8301 - HV9920.7 Penology. Prisons. Corrections',
               'H - Social sciences|HV1 - HV9960 Social pathology. Social and public welfare. Criminology|HV7231 - HV9960 Criminal justice administration|HV8301 - HV9920.7 Penology. Prisons. Corrections|HV9441 - HV9920.7 By region or country',
               'M - Music',
               'M - Music|ML1 - ML3930 Literature on music',
               'M - Music|ML1 - ML3930 Literature on music|ML93 - ML96.5 Manuscripts, autographs, etc.'
             ])
        )
    end
    end


end
