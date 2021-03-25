# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest

  it "primary_isbn only stores isbns that don't include the string 'exclude' in $q" do
    rec = make_rec
    rec << MARC::DataField.new('020', ' ', ' ', ['a', '9789575433742'])
    rec << MARC::DataField.new('020', ' ', ' ', ['a', '7777777777777'])
    result = run_traject_on_record('ncsu', rec)
    expect(result['primary_isbn']).to eq(['9789575433742', '7777777777777'])
  end

  it "primary_isbn only stores isbns that don't have 'exclude' in $q" do
    rec = make_rec
    rec << MARC::DataField.new('020', ' ', ' ', ['a', '9789575433742'], ['q', 'exclude'])
    rec << MARC::DataField.new('020', ' ', ' ', ['a', '7777777777777'])
    result = run_traject_on_record('ncsu', rec)
    expect(result['primary_isbn']).to eq(['7777777777777'])
  end

  it "primary_isbn only stores isbns that don't have 'exclude' in $q" do
    rec = make_rec
    rec << MARC::DataField.new('020', ' ', ' ', ['a', '7777777777777'])
    rec << MARC::DataField.new('020', ' ', ' ', ['a', '9789575433742 (pbk.)'], ['q', 'exclude'])
    result = run_traject_on_record('ncsu', rec)
    expect(result['primary_isbn']).to eq(['7777777777777'])
  end

  it "primary_isbn is nil if $q includes the string 'exclude'" do
    rec = make_rec
    rec << MARC::DataField.new('020', ' ', ' ', ['a', '9789575433742 (pbk.)'], ['q', 'exclude'])
    rec << MARC::DataField.new('020', ' ', ' ', ['a', '7777777777777'], ['q', 'exclude'])
    result = run_traject_on_record('ncsu', rec)
    expect(result['primary_isbn']).to be_nil
  end
end
