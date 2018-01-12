require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest

  # this file is a bit pathological, it has three identical URLs
  let(:findingaid) { run_traject_json('ncsu', 'multi-findingaid-856') }

  it 'generates 856s for every one in the document' do
    expect(findingaid['url']).to be_a(Array)
    urls = findingaid['url'].map { |x| JSON.parse(x) }
    expect(urls.length).to eq(3)
    findingaids = urls.select { |x| x['type'] == 'findingaid' }
    expect(findingaids.length).to eq(3)
  end
end
