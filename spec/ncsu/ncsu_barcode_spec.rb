require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:multi_barcode) { run_traject_json('ncsu', 'multi-findingaid-856') }

  # fake record, has no 856 and only item is online with no barcode
  let(:no_barcode) { run_traject_json('ncsu', 'online-item-no-856-no-barcode') }

  let(:expected_barcodes) do
    %w[HAJN-9058-00001 S02267142O S02267143P
       S02267048T S02267049U S02267050M
       S02267051N S02267346U S02244277S
       S02246737V S02245564S S02245565T
       S02245542O S02245543P S02245553Q
       S02245554R S02245555S S02245562Q
       S02245563R S02245566U S02935671X
       S02935672Y S02935673Z S02935674-
       S02245572R]
  end

  it 'generates multiple barcodes for test record' do
    barcodes = multi_barcode['barcodes']
    expect(barcodes).to be_a(Array)
    expect(barcodes).to match_array(expected_barcodes)
  end

  it 'generates empty barcode attribute for record with no barcoded items' do
    expect(no_barcode['barcodes']).to eq([])
  end
end
