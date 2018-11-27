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
end
