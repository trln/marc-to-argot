# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::Shared::Upc do
  include Util::TrajectRunTest
  let(:upc01) { run_traject_json('unc', 'misc_id_upc', 'mrc') }
  
  it '(MTA) sets upc' do
    result = upc01['upc']
    expect(result).to eq(
                        [
                          {'value' => '034571173412',
                           'type' => 'UPC'},
                          {'value' => '111',
                           'qual' => 'blah',
                           'type' => 'UPC'},
                          {'value' => '666',
                           'type' => 'UPC (canceled or invalid)'}
                        ]
    )
  end
end
