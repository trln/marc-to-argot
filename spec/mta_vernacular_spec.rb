# coding: utf-8
require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:title1) { run_traject_json('unc', 'vern_title1', 'mrc') }

  it '(MTA) sets included_work' do
    result = title1['title']['main']
    expect(result).to eq(
                        [{'value'=>'',
                          'author'=>'Saint-SaÃ«ns, Camille, 1835-1921.',
                          'title'=>['Quartets,', 'violins (2), viola, cello,', 'no. 2, op. 153,', 'G major']}                        ]
                      )
  end
end
