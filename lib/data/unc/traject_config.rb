################################################
# Primary ID
######
to_field "id", extract_marc(settings["specs"][:id], :first => true) do |rec, acc|
  acc.collect! {|s| "UNC#{s.delete("b.")}"}
end

################################################
# Local ID
######
to_field "local_id" do |rec, acc|
  primary = Traject::MarcExtractor.cached("907a").extract(rec).first
  primary = primary.delete(".") if primary

  local_id = {
    :value => primary,
    :other => []
  }

  # do things here for "Other"

  acc << local_id
end

################################################
# Institutiuon
######\
to_field "institution", literal("unc")

################################################
# Catalog Date
######

to_field "cataloged_date" do |rec, acc|
  cataloged = Traject::MarcExtractor.cached("909").extract(rec).first
  acc << Time.parse(cataloged).utc.iso8601 if cataloged
end

################################################
# Items
# https://github.com/trln/extract_marcxml_for_argot_unc/blob/master/attached_record_data_mapping.csv
######
item_map = {
  i: { key: 'id'},
  l: { key: 'library'},
  p: { key: 'call_number_scheme' },
  q: { key: 'call_number' },
  s: { key: 'status' },
}

to_field 'items' do |rec, acc|

  Traject::MarcExtractor.cached("999", :alternate_script => false).each_matching_line(rec) do |field, spec, extractor|
    if field.indicator2 == "1"
      item = {}

      field.subfields.each do |subfield|
        code = subfield.code.to_sym
        mapped = item_map.fetch(code, key: nil)[:key]
        item[mapped] = subfield.value unless mapped.nil?
      end

      if item.fetch('call_number_scheme', '') == '0'
        item['lcc_top'] = item['call_number'][0,1]
      end

    end

    acc << item.to_json if item

  end
end
