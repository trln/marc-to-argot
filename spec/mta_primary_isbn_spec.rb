# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest

  it "primary_isbn stores isbn when $q doesn't include the string 'exclude'" do
    rec = make_rec
    rec << MARC::DataField.new('020', ' ', ' ', ['a', '9789575433742'])
    result = run_traject_on_record('ncsu', rec)
    expect(result['primary_isbn']).to eq(['9789575433742'])
  end

  it "primary_isbn should be nill when $q includs the string 'exclude'" do
    rec = make_rec
    rec << MARC::DataField.new('020', ' ', ' ', ['a', '9789575433742 exclude'])
    result = run_traject_on_record('ncsu', rec)
    expect(result['primary_isbn']).to(be_nil)
  end

    it "primary_isbn should be nill when $q includs the string 'exclude'" do
    rec = make_rec
    rec << MARC::DataField.new('020', ' ', ' ', ['a', '9789575433742 (pbk.) exclude'])
    result = run_traject_on_record('ncsu', rec)
    expect(result['primary_isbn']).to(be_nil)
  end

end
