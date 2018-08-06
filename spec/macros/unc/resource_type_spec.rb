# coding: utf-8
require 'spec_helper'
describe MarcToArgot::Macros::UNC::ResourceType do
  include Util::TrajectRunTest
  let(:thesis1) { run_traject_json('unc', 'thesis1', 'mrc') }

  context 'LDR/06 = t' do
    context '008/24-27 contains m' do
      context '502 field present' do
        it '(UNC) resource_type = Thesis/Dissertation' do
          a = thesis1['resource_type']
          expect(a).to eq(['Thesis/Dissertation'])
        end
      end
    end
  end


end
