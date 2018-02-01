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
# Rollup ID
######

to_field "rollup_id", extract_marc("035a") do |rec, acc|
  acc.select! { |x| /^(\(OCoLC\))?\d+$/.match(x.to_s) }
  acc.map! { |x| x.sub('(OCoLC)', '') }
  acc.map! { |x| "OCLC#{x}" }
  acc.flatten!
  acc.uniq!
end

################################################
# Institutiuon
######
to_field 'institution', literal('duke')

################################################
# Items
######
def is_available?(items)
  items.any? { |i| i['status'].downcase.start_with?('available') rescue false }
end

def status_map
  @status_map ||= Traject::TranslationMap.new('duke/process_state')
end

def location_state_map
  @location_state_map ||= Traject::TranslationMap.new('duke/location_default_state')
end

def location_hierarchy_map
  @location_hierarchy_map ||= Traject::TranslationMap.new('duke/location_hierarchy')
end

def select_fields(rec, field_tag)
  rec.fields.select { |f| f.tag == field_tag }
end

def select_indicator2(rec, field_tag)
  select_fields(rec, field_tag).map { |field| field.indicator2 }
end

def find_subfield(rec, field_tag, subfield_code)
  select_fields(rec, field_tag).map do |field|
    field.subfields.find do |sf|
      sf.code == subfield_code
    end
  end
end

def subfield_has_value?(rec, field_tag, subfield_code, subfield_value)
  find_subfield(rec, field_tag, subfield_code).any? do |subfield|
    subfield.value == subfield_value
  end
end

def indicator_2_has_value?(rec, field_tag, indicator_value)
  select_indicator2(rec, field_tag).any? do |indicator|
    indicator == indicator_value
  end
end

def newspaper?(rec)
  subfield_has_value?(rec, '942', 'a', 'NP') ||
  (rec.leader.byteslice(7) == 's' && rec['008'].value.byteslice(21) == 'n')
end

def periodical?(rec)
  subfield_has_value?(rec, '942', 'a', 'JR') ||
  (rec.leader.byteslice(7) == 's' && rec['008'].value.byteslice(21) == 'p')
end

def serial?(rec)
  rec.leader.byteslice(7) == 's' ||
  subfield_has_value?(rec, '852', 'D', 'y') ||
  subfield_has_value?(rec, '942', 'a', 'AS')
end

def microform?(rec)
  subfield_has_value?(rec, '942', 'b', 'Microform')
end

def online?(rec)
  indicator_2_has_value?(rec, '856', ' ') ||
  indicator_2_has_value?(rec, '856', '0') ||
  indicator_2_has_value?(rec, '856', '1')
end

# TODO! Aleph makes it challenging to determine item status.
# This method duplicates the logic in aleph_to_endeca.pl
# that determines item status.
# Refactoring would help, but let's just get it working.
def item_status(rec, item)
  status_code = item['status_code'].to_s
  process_state = item['process_state'].to_s
  due_date = item['due_date'].to_s
  item_id = item['item_id'].to_s
  location_code = item['location_code'].to_s
  type = item['type'].to_s

  if !due_date.empty? && process_state != 'IT'
    status = 'Checked Out'
  elsif status_code == '00'
    status = 'Not Available'
  elsif status_code == 'P3'
    status = 'Ask at Reference Desk'
  elsif !process_state.empty?
    if process_state == 'NC'
      if newspaper?(rec) || periodical?(rec)
        if status_code == '03' || status_code == '08' || status_code == '02'
          status = 'Available - Library Use Only'
        else
          status = 'Available'
        end
      elsif microform?(rec)
        status = 'Ask at Circulation Desk'
      elsif item_id =~ /^B\d{6}/
        status = 'Ask at Circulation Desk'
      elsif location_state_map[location_code] == 'C' || location_state_map[location_code] == 'B'
        if status_code == '03' || status_code == '08' || status_code == '02'
          status = 'Available - Library Use Only'
        else
          status = 'Available'
        end
      elsif location_state_map[location_code] == 'N'
        status = 'Not Available'
      else
        if status_code == '03' || status_code == '08' || status_code == '02'
          status = 'Available - Library Use Only'
        else
          status = 'Ask at Circulation Desk'
        end
      end
    else
      if status_map[process_state]
        status = status_map[process_state]
      else
        status = 'UNKNOWN'
      end
    end
  elsif status_code == 'NI' || item_id =~ /^B\d{6}/
    if type == 'MAP' && status_code != 'NI'
      status = 'Available'
    elsif location_state_map[location_code] == 'A' || location_state_map[location_code] == 'B'
      if status_code == '03' || status_code == '08' || status_code == '02'
        status = 'Available - Library Use Only'
      else
        status = 'Available'
      end
    elsif location_state_map[location_code] == 'N'
      status = 'Not Available'
    else
      # NOTE! There's a whole set of additional elsif conditions in the Perl script,
      # the result of which seems to be to set the status to 'Ask at Circulation Desk'
      # no matter whether any condition is met.
      # It also sets %serieshash and $hasLocNote vars.
      # Skipping all that for now.
      # See line 5014 of aleph_to_endeca.pl
      status = 'Ask at Circulation Desk'
    end
  else
    if status_code == '03' || status_code == '08' || status_code == '02'
      status = 'Available - Library Use Only'
    else
      status = 'Available'
    end
  end

  if online?(rec) && status == 'Ask at Circulation Desk'
    status = 'Available'
    # NOTE! In the aleph_to_endeca.pl script (line 5082) there's some code
    #       about switching the location to PEI. But let's pretend
    #       that's not happening for now.
  end

  status
end

def map_locations_to_hierarchy(items)
  locations = ['duke']
  items.each do |item|
    loc_b = item.fetch('loc_b', nil)
    loc_n = item.fetch('loc_n', nil)
    locations << location_hierarchy_map[loc_b] if loc_b
    locations << location_hierarchy_map[loc_n] if loc_n
  end

  locations.map { |loc| loc.split('|') if loc }.flatten.map { |c| c.split(';') if c }.compact
end

to_field 'items' do |rec, acc, ctx|
  lcc_top = Set.new
  items = []
  barcodes = []

  Traject::MarcExtractor.cached('940', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
    item = {}

    field.subfields.each do |subfield|
      sf_code = subfield.code
      case sf_code
      when 'b'
        item['loc_b'] = subfield.value
      when 'c'
        item['loc_n'] = subfield.value
      when 'd'
        item['cn_scheme'] = subfield.value
      when 'h'
        item['call_no'] = subfield.value
      when 'n'
        item['copy_no'] = subfield.value
      when 'o'
        item['status_code'] = subfield.value
      when 'p'
        item['item_id'] = subfield.value.strip
        barcodes << subfield.value.strip
      when 'q'
        item['process_state'] = subfield.value
      when 'r'
        item['type'] = subfield.value
      when 'x'
        item['due_date'] = subfield.value
      when 'z'
        item['notes'] = subfield.value
      end
    end

    item['status'] = item_status(rec, item)

    if item.fetch('cn_scheme', '') == '0'
      item['cn_scheme'] = 'LC'
      lcc_top.add(item['call_no'][0, 1])
    end

    item.delete('process_state')
    item.delete('status_code')

    items << item
    acc << item.to_json if item
  end

  locations = map_locations_to_hierarchy(items)

  ctx.output_hash['lcc_top'] = lcc_top.to_a
  ctx.output_hash['available'] = 'Available' if is_available?(items)
  ctx.output_hash['location_hierarchy'] = arrays_to_hierarchy(locations) if locations
  ctx.output_hash['barcodes'] = barcodes if barcodes.any?

  map_call_numbers(ctx, items)
end

################################################
# Holdings
######

to_field 'holdings' do |rec, acc, context|
  Traject::MarcExtractor.cached('852', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
    holding = {}
    field.subfields.each do |sf|
      case sf.code
      when 'b'
        holding['loc_b'] = sf.value
      when 'c'
        holding['loc_n'] = sf.value
      when 'h'
        holding['class_number'] = sf.value
      when 'i'
        holding['cutter_number'] = sf.value
      when 'A'
        holding['summary'] = sf.value
      when 'B'
        holding['supplement'] = sf.value
      when 'C'
        holding['index'] = sf.value
      when 'z'
        holding['notes'] ||= []
        holding['notes'] << sf.value
      when 'E'
        holding['notes'] ||= []
        holding['notes'] << sf.value
      end
    end

    call_number = [holding.delete('class_number'),
                   holding.delete('cutter_number')].compact.join(' ')

    holding['call_no'] = call_number unless call_number.empty?

    summary = [holding.delete('summary'),
               holding.delete('index'),
               holding.delete('supplement')].compact.join('; ')

    holding['summary'] = summary unless summary.empty?

    # Remove rollup_id from output_hash if loc_b is SCL or ARCH
    # so that we don't rollup special collections records.
    if holding['loc_b'] =~ /^(SCL|ARCH)$/
      context.output_hash.delete('rollup_id')
    end

    acc << holding.to_json if holding.any?
  end
end
