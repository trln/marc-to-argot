################################################
# Primary ID
######
to_field 'id', extract_marc(settings['specs'][:id], :first => true) do |rec, acc|
  acc.collect! {|s| "UNC#{s}"}
end

################################################
# Local ID
######
to_field 'local_id' do |rec, acc|
  primary = Traject::MarcExtractor.cached('907a').extract(rec).first
  primary = primary.delete('.') if primary

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
to_field 'institution', literal('unc')

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

################################################
# Holdings
######

def location_shelf_display
  @location_shelf_display ||=Traject::TranslationMap.new('unc/location_shelf_code_to_display')
end

def location_library
  @location_library ||=Traject::TranslationMap.new('unc/location_shelf_to_location_library')
end

to_field 'holdings' do |rec, acc|
  holding = {}
  nine_twos = []
  nine_threes = {
    info: [],   # $2 = 852
    summary: [] # $2 = 866
  }

  Traject::MarcExtractor.cached('999|9*|', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
    nine_twos << field if field.indicator2 == '2'
    if field.indicator2 == '3'
      nine_threes[:info] << { id: field.subfields_with_code('0').first.value, field: field } if field.subfield_with_value_of_code?('852','2')
      nine_threes[:summary] << { id: field.subfields_with_code('0').first.value, field: field } if field.subfield_with_value_of_code?('866','2')
    end
  end

  nine_twos.each do |field|
    field.subfields.each do |sf|
      case sf.code
      when 'a'
        holding['record_id'] = sf.value
      when 'b'
        holding['library'] = location_library[sf.value]
        holding['location'] = location_shelf_display[sf.value]
      end
    end
  end

  nine_threes[:info].select { |i| i[:id] == holding['record_id'] }.each do |info|
    call_number_h = info[:field].subfield_values_from_code('h').join(' ')
    call_number_i = info[:field].subfield_values_from_code('i').join(' ')
    holding['call_number'] = call_number_h + call_number_i if call_number_h && call_number_i
    holding['notes'] = info[:field].subfield_values_from_code('z')
  end

  nine_threes[:summary].select { |i| i[:id] == holding['record_id'] }.each do |summary|
    holding['summary'] = summary[:field].subfield_values_from_code('a').first
  end

  acc << holding.to_json if holding.any?
end
