require 'set'
require 'pp'
################################################
# Primary ID
######
to_field 'id', extract_marc(settings['specs'][:id], first: true) do |_rec, acc|
  acc.collect! { |s| "NCSU#{s}" }
end

################################################
# Local ID

to_field 'local_id', extract_marc(settings['specs'][:id], first: true) do |_rec, acc|
  acc.map! { |x| { value: x, other: [] } }
end

to_field 'institution', literal('ncsu')

to_field 'rollup_id', rollup_id

to_field 'items', extract_items

def shadowed_location?(item)
  %w[BOTMISSING ACQ-S MISSING].include?(item['loc_n'])
end

each_record do |_rec, ctx|
  items = ctx.clipboard['items']
  items.reject! { |i| shadowed_location?(i) }
  ctx.skip! if items.empty?

  ctx.output_hash['barcodes'] = items.map { |x| x['item_id'] }.select(&:itself)

  if ctx.output_hash.fetch('format', []).include?('Journal/Newspaper')
    holdings = generate_holdings(items)
    ctx.output_hash['holdings'] = holdings.map(&:to_json)
  end
end
