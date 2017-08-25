################################################
# Primary ID
######
to_field 'id', extract_marc(settings['specs'][:id], first: true) do |rec, acc|
  acc.collect! {|s| "#{s}"}
end

################################################
# Local ID
######

to_field 'local_id' do |rec, acc, context|

  local_id = {
    value: context.output_hash['id'].first,
    other: []
  }

  acc << local_id

end


################################################
# Institutiuon
######
to_field 'institution', literal('duke')

################################################
# Catalog Date
######

################################################
# Items
######
item_map = {
  p: { key: 'barcode' },
  n: { key: 'copy_number' },
  b: { key: 'library' },
  z: { key: 'note' },
  h: { key: 'call_number' },
  o: { key: 'status' },
  c: { key: 'shelving_location' },
  r: { key: 'type' },
  n: { key: 'volume' },
  d: { key: 'call_number_scheme' }
}

to_field 'items' do |rec, acc, ctx|

  lcc_top = Set.new
  items = []

  Traject::MarcExtractor.cached('940', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
    item = {}

    field.subfields.each do |subfield|
      code = subfield.code.to_sym
      mapped = item_map.fetch(code, key: nil)[:key]
      item[mapped] = subfield.value unless mapped.nil?
    end

    if item.fetch('call_number_scheme', '') == '0'
      item['call_number_scheme'] = 'LC'
      lcc_top.add(item['call_number'][0, 1])
    end

    items << item
    acc << item.to_json if item
  end
  ctx.output_hash['lcc_top'] = lcc_top.to_a
  map_call_numbers(ctx, items)
end

