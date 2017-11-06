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
# Institution
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
  available_statuses = ['Ask the MRC', 'Available', 'Contact library for status', 'In-Library Use Only']
  items.any? { |i| available_statuses.include?(i['status']) rescue false }
end

def set_cn_scheme(marc_tag, i1, i2)
  case marc_tag
  when '050'
    'LC'
  when '060'
    'NLM'
  when '070'
    'NAL'
  when '082'
    'DDC'
  when '083'
    'DDC'
  when '090'
    'LC'
  when '092'
    'DDC'
  when '086'
    if i1 == '0'
      'SUDOC'
    else
      'OTHERGOVDOC'
    end
  when '099'
    'ALPHANUM'
  end
end

to_field 'items' do |rec, acc, ctx|

  formats = marc_formats.call(rec, [])
  items = []

  Traject::MarcExtractor.cached('999|*1|cdilnpqsv', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|

    item = {}
    public_notes = []

    field.subfields.each do |subfield|
      sf = subfield.code
      subfield.value.gsub!(/\|./, ' ') #remove subfield delimiters and
      subfield.value.strip! #delet leading/trailing spaces
      case sf
      when 'c'
        item['copy_no'] = subfield.value if subfield.value != '1'
      when 'd'
        item['due_date'] = subfield.value
      when 'i'
        item['id'] = subfield.value
      when 'l'
        item['loc_b'] = subfield.value
        item['loc_n'] = subfield.value
      when 'n'
        public_notes << subfield.value
      when 'p'
        item['cn_scheme'] = set_cn_scheme(subfield.value[0, 3], subfield.value[3], subfield.value[4])
      when 'q'
        item['call_no'] = subfield.value
      when 's'
        item['status'] = status_map[subfield.value]
      when 'v'
        item['vol'] = subfield.value
      end
    end

    #add notes to item
    item['notes'] = public_notes if public_notes.size > 0

    #set checked out status
    item['status'] = 'Checked out' if item['due_date']

    items << item
    acc << item.to_json if item

    #set Availability facet value affirmatively
    ctx.output_hash['available'] = 'Available' if is_available?(items)
    map_call_numbers(ctx, items)
  end
end

################################################
# Holdings
######

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
        holding['holdings_id'] = sf.value
      when 'b'
        holding['loc_b'] = sf.value
        holding['loc_n'] = sf.value
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
