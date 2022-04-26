# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest

  context '250 field present' do
    context 'AND 250$b present' do
      it '(MTA) sets edition[label] from 250$3' do
        rec = make_rec
        rec << MARC::DataField.new('250', ' ', ' ',
                                   ['a', 'Edicion premiere ='],
                                   ['b', 'First edition'])
        result = run_traject_on_record('unc', rec)['edition']
        expect(result).to eq(
                            [
                              {'value' => 'Edicion premiere = First edition'}
                            ]
                          )
      end
      
    end
    context 'AND 250$3 present' do
      it '(MTA) sets edition[label] from 250$3' do
        rec = make_rec
        rec << MARC::DataField.new('250', ' ', ' ',
                                   ['3', 'Vol. 2:'],
                                   ['a', '1a ed.'])
        result = run_traject_on_record('unc', rec)['edition']
        expect(result).to eq(
                            [
                              {'label' => 'Vol. 2', 'value' => '1a ed.'}
                            ]
                          )
      end
    end

    context 'AND 880 linked to 250 present' do
      it '(MTA) sets edition from 250 and 880, assigning lang code to 880 value' do
        rec = make_rec
        rec << MARC::DataField.new('250', ' ', ' ',
                                   ['6', '880-04'],
                                   ['a', '︠I︡Ubileĭnoe izd.'])
        rec << MARC::DataField.new('880', ' ', ' ',
                                   ['6', '250-04/(N'],
                                   ['a', 'Юбилейное изд.'])
        result = run_traject_on_record('unc', rec)['edition']
        expect(result).to eq(
                            [
                              {'value' => '︠I︡Ubileĭnoe izd.' },
                              { 'value' => 'Юбилейное изд.',
                                'lang' => 'rus' }
                            ]
                          )
      end
    end

    context 'AND 250 itself contains non-Roman characters' do
      it '(MTA) sets edition from 250, assigning lang code to value' do
        rec = make_rec
        rec << MARC::DataField.new('250', ' ', ' ',
                                   ['a', '2015年デジタル版'])
        result = run_traject_on_record('unc', rec)['edition']
        expect(result).to eq(
                            [
                              { 'value' => '2015年デジタル版',
                                'lang' => 'cjk' }
                            ]
                          )
      end
    end
  end

  context '251 field present' do
    context 'AND 251$3 present' do
      it '(MTA) sets edition with label value from 251' do
        rec = make_rec
        rec << MARC::DataField.new('251', ' ', ' ',
                                   ['3', '2015 report:'],
                                   ['a', 'Draft'],
                                   ['2', 'somecode'])
        result = run_traject_on_record('unc', rec)['edition']
        expect(result).to eq(
                            [
                              {'label' => '2015 report',
                               'value' => 'Draft'}
                            ]
                          )
      end
    end
  end

  context '254 field present' do
    it '(MTA) sets edition from 254' do
      rec = make_rec
      rec << MARC::DataField.new('254', ' ', ' ',
                                 ['a', 'Study score'])
      result = run_traject_on_record('unc', rec)['edition']
      expect(result).to eq(
                          [
                            {'value' => 'Study score'}
                          ]
                        )
    end
  end

  context 'both 250 and 254 fields present' do
    it '(MTA) sets edition from both fields, in order of their occurrence in record' do
      rec = make_rec
      rec << MARC::DataField.new('250', ' ', ' ',
                                 ['a', '3rd ed.'])
      rec << MARC::DataField.new('254', ' ', ' ',
                                 ['a', 'Choir edition.'])
      result = run_traject_on_record('unc', rec)['edition']
      expect(result).to eq(
                          [
                            {'value' => '3rd ed.'},
                            {'value' => 'Choir edition.'}
                          ]
                        )
    end
  end



end
