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

################################################
# Catalog Date
######

################################################
# Items
######
item_map = {
  i: { key: 'barcode' },
  c: { key: 'copy_number' },
  m: { key: 'library' },
  o: { key: 'note' },
  a: { key: 'call_number' },
  k: { key: 'current_location' },
  l: { key: 'shelving_location' },
  t: { key: 'type' },
  v: { key: 'volume' },
  w: { key: 'call_number_scheme' }
}

to_field 'holdings_library', extract_marc('999m') do |_rec, acc|
  acc.uniq!
end

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
    'Unknown'
  end
end

to_field 'items' do |rec, acc|
  Traject::MarcExtractor.cached('999', alternate_script: false).each_matching_line(rec) do |field, _s, _e|
    item = {}

    field.subfields.each do |subfield|
      code = subfield.code.to_sym
      mapped = item_map.fetch(code, key: nil)[:key]
      item[mapped] = subfield.value unless mapped.nil?
    end

    # $k is only present if current != hom
    # needs refinement for reserves etc. and non-lending items
    current = item['current_location']
    home = item['shelving_location']
    item['status'] = item_status(current, home)

    if item.fetch('call_number_scheme', '') == 'LC'
      item['lcc_top'] = item['call_number'][0, 1]
    end
    acc << item.to_json if item
  end
end
