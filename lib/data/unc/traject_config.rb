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
# Items
# https://github.com/trln/extract_marcxml_for_argot_unc/blob/master/attached_record_data_mapping.csv
######
def status_map
  @status_map ||=Traject::TranslationMap.new('unc/status_map')
end

def is_available?(items)
  items.any? { |i| i['status'].downcase.start_with?('available') rescue false }
end

item_map = {
  i: { key: 'id' },
  l: { key: 'library' },
  p: { key: 'call_number_scheme' },
  q: { key: 'call_number' },
  s: { key: 'status', translation_map: status_map }
}


to_field 'items' do |rec, acc, ctx|

  lcc_top = Set.new
  formats = marc_formats.call(rec, [])
  lcc_scheme_codes = %w[090 050]
  items = []

  Traject::MarcExtractor.cached('999', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
    if field.indicator2 == '1'
      item = {}

      field.subfields.each do |subfield|
        code = subfield.code.to_sym
        map_hash = item_map.fetch(code, key: nil)
        unless map_hash.nil?
          item[map_hash[:key]] = map_hash[:translation_map] ? map_hash[:translation_map][subfield.value] : subfield.value
        end
      end


      if lcc_scheme_codes.include?(item.fetch('call_number_scheme', ''))
        item['call_number_scheme'] = 'LC'
        lcc_top.add(item['call_number'].gsub!(/\|\w/, '')[0, 1])
      end
      items << item
      acc << item.to_json if item

    end
    ctx.output_hash['lcc_top'] = lcc_top.to_a
    ctx.output_hash['available'] = 'Available' if is_available?(items)
    map_call_numbers(ctx, items)
  end
end
