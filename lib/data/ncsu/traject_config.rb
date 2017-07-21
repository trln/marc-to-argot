################################################
# Primary ID
######
to_field "id", extract_marc(settings["specs"][:id], :first => true) do |rec, acc|
  acc.collect! {|s| "NCSU#{s}"}
end


################################################
# Local ID
#####
#
to_field 'local_id', extract_marc(settings['specs'][:id], first: true) do |rec, acc|
  acc = [ { value: acc.first, other: [] } ]
end

################################################
# Institutiuon
######
to_field "institution", literal("ncsu")

################################################
# Catalog Date
######

################################################
# Items
######
item_map = {
  i: { key: 'barcode' },
  c: { key: 'copy_number', },
  m: { key: 'library', },
  o: { key: 'note', },
  a: { key: 'call_number', },
  k: { key: 'status', },
  l: { key: 'shelving_location' },
  t: { key: 'type' },
  v: { key: 'volume' },
  w: { key: 'call_number_scheme' }
}

to_field 'holdings_library', extract_marc('999m') do |rec, acc|
  acc.uniq!
end

to_field "items" do |rec, acc|

  Traject::MarcExtractor.cached("999", :alternate_script => false).each_matching_line(rec) do |field, spec, extractor|
    item = {}

    field.subfields.each do |subfield|
      code = subfield.code.to_sym
      mapped = item_map.fetch(code, {key:nil})[:key]
      item[mapped] = subfield.value unless mapped.nil?
    end

    if item.fetch(:call_number_scheme, '') == 'LC'
      item[:lcc_top] = item[:call_number][0,1]
    end
    acc << item.to_json if item
  end
end
