# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::UNC do
  include Util
  
  let(:indexer) { MarcToArgot::Indexers::UNC.new }
  let(:url_recs) { MARC::XMLReader.new(find_marc('unc', 'url_spec')).to_a }
  let(:expected_text) {
    [
      #1
      ['v. 1 -- Full text available via the UNC-Chapel Hill Libraries',
       'v. 2 -- Full text available via the UNC-Chapel Hill Libraries',
       'v. 3 -- Full text available via the UNC-Chapel Hill Libraries'],
      #2
      ['Bd.1 -- Available via the UNC-Chapel Hill Libraries',
       'Bd.2 -- Available via the UNC-Chapel Hill Libraries'],
      #3
      ['Full text available via the UNC-Chapel Hill Libraries'],
      #4
      ['Available via the UNC-Chapel Hill Libraries'],
      #5
      ['Finding aid to the Archie Green archival collection'],
      #6
      ['More information about this item in: Russia Beyond Russia: The André Savine Digital Library'],
      #7
      ['Thumbnail image',
       'DOWNLOAD DATA HERE'],
      #8
      nil,
      #9
      ['Table of contents only'],
      #10
      ['Available via the UNC-Chapel Hill Libraries'],
      #11
      nil,
      #12
      ['PDF version -- Available via the UNC-Chapel Hill Libraries'],
    ]
  }

  let(:expected_type) {
    [
      #1
      ['fulltext',
       'fulltext',
       'fulltext'],
      #2
      ['fulltext',
       'fulltext'],
      #3
      ['fulltext'],
      #4
      ['fulltext'],
      #5
      ['findingaid'],
      #6
      ['related'],
      #7
      ['thumbnail',
       'fulltext'],
      #8
      ['other'],
      #9
      ['other'],
      #10
      ['fulltext'],
      #11
      nil,
      #12
      ['fulltext']
    ]
  }
  
  it 'extracts link text' do
    indexer.instance_eval do
      each_record do |rec, cxt|
        url(rec, cxt)
      end
    end
    url_recs.each_with_index do |rec, idx|
      exp = expected_text[idx]
      unless exp.nil?
        argotout = indexer.map_record(rec)
        urlfield = argotout['url']
        output = urlfield.map { |u| JSON.parse(u)['text'] } #unless urlfield.empty?
        expect(output.length).to eq(exp.length), "Record #{idx +1} in error\nExpected:\n#{exp}\nOutput:\n #{output}"
        expect(output).to eq(exp)
      end
    end
  end

  it 'extracts link type' do
    indexer.instance_eval do
      each_record do |rec, cxt|
        url(rec, cxt)
      end
    end
    url_recs.each_with_index do |rec, idx|
      exp = expected_type[idx]
      unless exp.nil?
        argotout = indexer.map_record(rec)
        urlfield = argotout['url']
        output = urlfield.map { |u| JSON.parse(u)['type'] } #unless urlfield.empty?
        expect(output.length).to eq(exp.length), "Record #{idx +1} in error\nExpected:\n#{exp}\nOutput:\n #{output}"
        expect(output).to eq(exp)
      end
    end
  end

end
