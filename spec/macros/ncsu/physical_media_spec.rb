require 'spec_helper'

describe MarcToArgot::Macros::NCSU::PhysicalMedia do
  include described_class
  include Util::TrajectRunTest

  class Context
    def initialize(clipboard ={})
      @clipboard = clipboard
    end

    def clipboard
      @clipboard ||= {}
    end
  end

  def macro_context(*items)
    [nil, [], Context.new({ 'items' => items })]
  end

  let(:online_ebook_item) { stringhash(loc_b: 'ONLINE', type: 'EBOOK') }

  # this is a Kindle, e.g.
  let(:hill_ebook_item) { stringhash(loc_b: 'DHHILL', type: 'EBOOK') }

  let(:bookbot_microfiche_item) do
    stringhash(
      loc_b: 'HUNT',
      loc_n: 'BOOKBOT',
      type: 'MICROFICHE'
    )
  end

  let(:test_1) {  run_traject_json('ncsu', 'pm_test1') }

  let(:test_2) {  run_traject_json('ncsu', 'pm_test2') }

  it 'does not assign a physical media type to online materials' do
    ctx = macro_context(online_ebook_item)
    physical_media.call(ctx[0], ctx[1], ctx[2])
    expect(ctx[1]).to eq([])
  end

  it 'assigns E-Reader to EBOOK/DHHILL' do
    ctx = macro_context(hill_ebook_item)
    physical_media.call(*ctx)
    expect(ctx[1]).to eq(['E-reader or player'])
  end

  it 'assigns Microfiche to a MICROFICHE' do
    ctx = macro_context(bookbot_microfiche_item)
    physical_media.call(*ctx)
    expect(ctx[1]).to eq(['Microform > Microfiche'])
  end

  it 'correctly maps physical_media for e-reader record 1' do
    expect(test_1['physical_media']).to eq(['Online'])
  end

  it 'correctly maps physical_media for e-reader record 2' do
    expect(test_2['physical_media']).to eq(['Microform > Microfiche'])
  end
end
