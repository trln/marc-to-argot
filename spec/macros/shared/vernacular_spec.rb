# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::Shared::Vernacular do
  include Util::TrajectRunTest
  field = MARC::DataField.new('880')
  value = 'Уварова, Прасковья Сергѣевна, графиня. 1840-1924.'

  it 'classifies the script of the field' do
    result = MarcToArgot::Macros::Shared::Vernacular::ScriptClassifier.new(field, value).classify
    expect(result).to eq('rus')
  end
end
