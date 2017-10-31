require 'set'
extend MarcToArgot::CallNumbers
extend MarcToArgot::Macros::NCSU

################################################
# Primary ID
######
to_field 'id', extract_marc(settings['specs'][:id], first: true) do |_rec, acc|
  acc.collect! { |s| "NCSU#{s}" }
end

################################################
# Local ID
# rubocop:disable LineLength
to_field 'local_id', extract_marc(settings['specs'][:id], first: true) do |_rec, acc|
  acc.map! { |x| { value: x, other: [] } }
end

################################################
# Institutiuon
######
to_field 'institution', literal('ncsu')

to_field 'rollup_id', ncsu_rollup_id

################################################
# Catalog Date
######

################################################
# Items
######
item_map = {
  i: { key: 'item_id' },
  c: { key: 'copy_no' },
  m: { key: 'loc_b' },
  o: { key: 'notes' },
  a: { key: 'call_no' },
  k: { key: 'loc_current' },
  l: { key: 'loc_n' },
  t: { key: 'type' },
  v: { key: 'vol' },
  w: { key: 'cn_scheme' }
}

# rubocop:disable MethodLength
def item_status(current, home)
  if current.nil? || current.empty?
    'Available'
  elsif current =~ /RSRV/
    'On Reserve'
  elsif current == 'CHECKEDOUT'
    'Checked Out'
  elsif current == home
    'Available'
  else
    "Unknown (#{current})"
  end
end

# ru#bocop:disable Metrics/BlockLength
to_field 'items' do |rec, acc, ctx|
  items = []
  Traject::MarcExtractor.cached('999', alternate_script: false).each_matching_line(rec) do |field, _s, _e|
    item = {}
    field.subfields.each do |subfield|
      code = subfield.code.to_sym
      mapped = item_map.fetch(code, key: nil)[:key]
      item[mapped] = subfield.value unless mapped.nil?
    end
    # $k is only present if current != home
    # needs refinement for reserves etc. and non-lending items
    current = item['loc_current']
    home = item['loc_n']
    item['status'] = item_status(current, home)
    items << item
    acc << item.to_json if item
  end
  map_call_numbers(ctx, items)
end
