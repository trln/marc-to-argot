require 'spec_helper'

describe MarcToArgot::Macros do
  include described_class

  let(:open_access_law) { run_traject_json('nccu', 'open_access_restricted_law', 'xml') }
  let(:open_access_gov) { run_traject_json('nccu', 'open_access_restricted_gov', 'xml') }
  let(:open_access_edu) { run_traject_json('nccu', 'open_access_restricted_edu', 'xml') }
  let(:open_access_com) { run_traject_json('nccu', 'open_access_restricted_false', 'xml') }

  context 'NCCU' do
    it 'sets restricted to true for open access URLs with law' do
      expect(JSON.parse(open_access_law['url'][0])['restricted']).to(
        eq nil
      )
    end

    it 'sets restricted to true for open_access URLs with gov' do
      expect(JSON.parse(open_access_gov['url'][0])['restricted']).to(
        eq nil
      )
    end

    it 'sets restricted to true for open_access URLs with edu' do
      expect(JSON.parse(open_access_gov['url'][0])['restricted']).to(
        eq nil
      )
    end

    it 'sets restricted to false for open_access URLs' do
      expect(JSON.parse(open_access_com['url'][0])['restricted']).to(
        eq(false)
      )
    end
  end
end
