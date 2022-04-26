# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest

  it "value should include both a and z with ISBN prepended to z" do
    rec = make_rec
    rec << MARC::DataField.new('581', ' ', ' ', ['a', 'Levine, Lawrence W. "William Shakespeare and the American People: A Study in Cultural Transformation." American Historical Review, 89 (February 1984).'], ['z', '9789575433741'])
    result = run_traject_on_record('ncsu', rec)
    expect(result['note_related_work']).to eq([{indexed: 'false', value: 'Levine, Lawrence W. "William Shakespeare and the American People: A Study in Cultural Transformation." American Historical Review, 89 (February 1984). ISBN 9789575433741', label: 'Related publications'}])
  end

  it "label should be 'Publications relating to preliminary report'" do
    rec = make_rec
    rec << MARC::DataField.new('581', ' ', ' ', ['a', 'Levine, Lawrence W. "William Shakespeare and the American People: A Study in Cultural Transformation." American Historical Review, 89 (February 1984).'], ['z', '9789575433741'], ['3', 'Preliminary report'])
    result = run_traject_on_record('ncsu', rec)
    expect(result['note_related_work']).to eq([{indexed: 'false', value: 'Levine, Lawrence W. "William Shakespeare and the American People: A Study in Cultural Transformation." American Historical Review, 89 (February 1984). ISBN 9789575433741', label: 'Publications relating to preliminary report'}])
  end

end
