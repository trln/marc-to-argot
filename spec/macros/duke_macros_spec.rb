# coding: utf-8

require 'spec_helper'

describe MarcToArgot::Macros::Duke do
  include Util

  let(:indexer) { MarcToArgot::Indexers::Duke.new }
  let(:url_recs) { MARC::Reader.new(find_marc('duke', 'url', 'mrc')).to_a }
  let(:expected_note) do
    [['Duke law journal, v. 50, no. 6',
      'Duke law journal, v. 50, no. 6',
      'Duke law journal, v. 50, no. 6'],
     [nil, nil],
     ['Text version:', 'PDF version:'],
     [nil, nil]]
  end
  let(:expected_text) do
    [[nil, nil, nil],
     ['Collection guide', 'Finding aid'],
     [nil, nil],
     [nil, nil]]
  end

  let(:expected_type) do
    [%w[other other other],
     %w[findingaid findingaid],
     %w[fulltext fulltext],
     %w[fulltext other]]
  end

  it 'extracts link note' do
    indexer.instance_eval do
      to_field 'url', url
    end
    url_recs.each_with_index do |rec, idx|
      exp = expected_note[idx]
      next if exp.nil?
      argotout = indexer.map_record(rec)
      urlfield = argotout['url']
      output = urlfield.map { |u| JSON.parse(u)['note'] }
      expect(output.length).to eq(exp.length), "Record #{idx + 1} in error\nExpected:\n#{exp}\nOutput:\n #{output}"
      expect(output).to eq(exp)
    end
  end

  it 'extracts link text' do
    indexer.instance_eval do
      to_field 'url', url
    end
    url_recs.each_with_index do |rec, idx|
      exp = expected_text[idx]
      next if exp.nil?
      argotout = indexer.map_record(rec)
      urlfield = argotout['url']
      output = urlfield.map { |u| JSON.parse(u)['text'] }
      expect(output.length).to eq(exp.length), "Record #{idx + 1} in error\nExpected:\n#{exp}\nOutput:\n #{output}"
      expect(output).to eq(exp)
    end
  end

  it 'extracts link type' do
    indexer.instance_eval do
      to_field 'url', url
    end
    url_recs.each_with_index do |rec, idx|
      exp = expected_type[idx]
      next if exp.nil?
      argotout = indexer.map_record(rec)
      urlfield = argotout['url']
      output = urlfield.map { |u| JSON.parse(u)['type'] }
      expect(output.length).to eq(exp.length), "Record #{idx + 1} in error\nExpected:\n#{exp}\nOutput:\n #{output}"
      expect(output).to eq(exp)
    end
  end

  it 'removes leading zeros from oclc numbers' do
    result = run_traject_json('duke', 'oclc_leading_zeros', 'xml')
    expect(result['oclc_number']).to(eq({"value"=>"503275"}))
  end

  it 'sets rollup_id from oclc number with leading zeros removed' do
    result = run_traject_json('duke', 'oclc_leading_zeros', 'xml')
    expect(result['rollup_id']).to(eq("OCLC503275"))
  end

  it 'adds donor names as an indexed-only local note' do
    rec = make_rec
    rec << MARC::DataField.new('796', ' ', ' ', ['z', 'Gift of L.A.G.'])
    result = run_traject_on_record('duke', rec)
    expect(result['note_local']).to eq([{ 'indexed_value' => 'Gift of L.A.G.' }])
  end

  it 'adds donor names to the donor field' do
    rec = make_rec
    rec << MARC::DataField.new('796', ' ', ' ', ['z', 'Gift of L.A.G.'])
    result = run_traject_on_record('duke', rec)
    expect(result['donor']).to eq(['Gift of L.A.G.'])
  end

  it 'removes Print from Archival records' do
    result = run_traject_json('duke', 'archival_print', 'xml')
    expect(result['physical_media']).to be_nil
  end

  it 'adds the bib number as an indexed only misc_id' do
    result = run_traject_json('duke', 'archival_print', 'xml')
    expect(result['misc_id']).to include({"display"=>"false", "value"=>"005314421"})
    expect(result['misc_id']).to include({"display"=>"false", "value"=>"5314421"})
  end
end
