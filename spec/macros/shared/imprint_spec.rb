# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::Shared::Imprint do
  include Util

  describe 'imprints' do
    let(:indexer) { MarcToArgot::Indexers::UNC.new }
    let(:records) { MARC::XMLReader.new(find_marc('unc', 'imprint')).to_a }
    let(:imprint_main_expectation) {
      [[{ 'type' => 'imprint',
          'value' => 'London : Writers and Readers Pub. Cooperative Society ; '\
                     'New York, N.Y. : Distributed in the U.S.A. by W.W. Norton, 1980 (1982 printing)' }],
       [{ 'type' => 'imprint',
          'label' => 'Fall/Winter 2002-',
          'value' => 'Savannah, GA : Dept. of Languages, Literature & Philosophy, '\
                     'Armstrong Atlantic State University' }],
       [{ 'type' => 'imprint',
          'label' => '1986-1989',
          'value' => 'New York : Applause Theater Book Publishers,' }],
       [{ 'type' => 'publication',
          'value' => '[Place of publication not identified] : Channel Four (Great Britain), [2014]' }],
       [{ 'type' => 'production',
          'value' => 'New Brunswick : Transaction Publishers, -1994.' }],
       [{ 'type' => 'production',
          'label' => '<1927, no. 18-19>',
          'value' => 'Rīgā : [publisher not identified]' },
          'type' => 'production',
          'label' => '<1927, nо. 5-16>',
          'value' => 'Paris : О.Д. Строкъ'],
       [{ 'type' => 'distribution',
          'value' => '[Buffalo, NY] : William S. Hein & Company, [2009]' }]]
    }

    let(:imprint_multiple_expectation) {
      [nil,
       [{ 'type' => 'imprint',
          'value' => 'Raleigh, N.C. : Published by the editors in cooperation with the School of '\
                     'Liberal Arts at North Carolina State of the University of North Carolina, [1964-' },
        { 'type' => 'imprint',
          'label' => 'Spring 1978-winter 1995',
          'value' => 'Charlotte, N.C. : English Dept., UNCC' },
        { 'type' => 'imprint',
          'label' => 'Summer 1996-winter 1999',
          'value' => 'Charlotte, N.C. : Advancment Studies, CPCC' },
        { 'type' => 'imprint',
          'label' => 'Summer 2000-summer 2001',
          'value' => 'Charlotte, N.C. : English Dept., CPCC' },
        { 'type' => 'imprint',
          'label' => 'Fall/Winter 2002-',
          'value' => 'Savannah, GA : Dept. of Languages, Literature & Philosophy, '\
                     'Armstrong Atlantic State University' }],
       [{ 'type' => 'imprint',
          'value' => 'New York : Dodd, Mead, 1953-c1989.' },
        { 'type' => 'imprint',
          'label' => '1968-1971, 1973-1985',
          'value' => 'Boston : Beacon Press,' },
        { 'type' => 'imprint',
          'label' => '<1972>',
          'value' => 'Philadelphia ; New York : Chilton Book Co.,' },
        { 'type' => 'imprint',
          'label' => '1986-1989',
          'value' => 'New York : Applause Theater Book Publishers,' }],
       [{ 'type' => 'publication',
          'value' => '[Place of publication not identified] : Channel Four (Great Britain), [2014]' },
        { 'type' => 'copyright',
          'value' => '©2014' },
        { 'type' => 'distribution',
          'value' => 'New York, N.Y. : Films Media Group, 2015' }],
       [{ 'type' => 'imprint',
          'value' => '[New Brunswick, N.J. : Douglass College, Rutgers University, 1979-' },
        { 'type' => 'production',
          'value' => 'New Brunswick : Transaction Publishers, -1994.' }],
       [{ 'type' => 'production',
          'value' => 'Riga : "N. Niva, "' },
        { 'type' => 'production',
          'label' => '<1927, no. 5-16>',
          'value' => 'Paris : O.D. Strokʺ' },
        { 'type' => 'production',
          'label' => '<1927, no. 18-19>',
          'value' => 'Rīgā : [publisher not identified]' },
        { 'type' => 'production','value' => 'Рига : "Н. Нива, "' },
        { 'type' => 'production','label' => '<1927, nо. 5-16>','value' => 'Paris : О.Д. Строкъ' }
       ],
       [{ 'type' => 'distribution',
          'value' => 'Buffalo, New York : William S. Hein & Co., 1997.' },
        { 'type' => 'distribution',
          'value' => '[Buffalo, NY] : William S. Hein & Company, [2009]' }]]
    }
    let(:imprint_v1) { run_traject_json('unc', 'imprint_v1', 'mrc') }
    let(:imprint_v2) { run_traject_json('unc', 'imprint_v2', 'mrc') }
    let(:imprint_vern) { run_traject_json('duke', 'imprint_vern') }

    it 'extracts imprint_main' do
      indexer.instance_eval do
        to_field 'imprint_main', imprint_main
      end
      records.each_with_index do |rec, idx|
        output = indexer.map_record(rec)
        exp = imprint_main_expectation[idx]
        expect(output['imprint_main'].length).to eq(exp.length) unless exp.nil?
        expect(output['imprint_main']).to eq(exp.nil? ? nil : exp.map { |v| v.to_json })
      end
    end

    it 'extracts imprint_multiple' do
      indexer.instance_eval do
        to_field 'imprint_multiple', imprint_multiple
      end
      records.each_with_index do |rec, idx|
        output = indexer.map_record(rec)
        exp = imprint_multiple_expectation[idx]
        expect(output['imprint_multiple'].length).to eq(exp.length) unless exp.nil?
        expect(output['imprint_multiple']).to eq(exp.nil? ? nil : exp.map { |v| v.to_json  })
      end
    end

    it '(MTA) sets imprint_main from 260 and linked 880' do
      result = imprint_v1['imprint_main']
      expect(result).to eq(
                          [
                            {
                              'type': 'imprint',
                             'label': 'vyp. 4-',
                             'value': 'Moskva : Nauka.'
                            }.to_json,
                            {
                              'type': 'imprint',
                             'label': 'вып. 4-',
                             'value': 'Москва : Наука'
                            }.to_json
                          ]
                        )
    end

    it '(MTA) sets imprint_multiple from 260 and linked 880' do
      result = imprint_v1['imprint_multiple']
      expect(result).to eq(
                          [
                            {
                              'type': 'imprint',
                             'value': 'Moskva : In-t vseobshcheĭ istorii RAN, 2000-'
                            }.to_json,
                            {
                              'type': 'imprint',
                             'label': 'vyp. 4-',
                             'value': 'Moskva : Nauka.'
                            }.to_json,
                            {
                              'type': 'imprint',
                             'value': 'Москва : Ин-т всеобщей истории РАН, 2000-'
                            }.to_json,
                            {
                              'type': 'imprint',
                             'label': 'вып. 4-',
                             'value': 'Москва : Наука'
                            }.to_json
                          ]
                        )
    end

    it '(MTA) sets non-roman imprint_main from 260' do
      result = imprint_v2['imprint_main']
      expect(result).to eq(
                          [
                            {
                              'type': 'imprint',
                             'value': '[S.l.] : 秋田大学教育文化学部附属教育実践総合センター'
                            }.to_json
                          ]
                        )
    end

    it 'sets publisher_location from main imprint' do
      result = imprint_v1['publisher_location']
      expect(result).to eq(["Moskva", "Москва"])
    end

    it 'sets imprint_main when there is a single linked field' do
      result = imprint_vern['imprint_main']
      expect(result.length).to eq(2)
    end

    it 'does not set imprint_multiple if it would be same as imprint_main' do
      result = imprint_vern['imprint_multiple']
      expect(result).to be nil
    end
  end
end
