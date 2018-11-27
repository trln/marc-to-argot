each_record do |rec, cxt|
  set_shared_record_set_code(rec, cxt)
end

################################################
# Primary ID
######
to_field 'id', extract_marc(settings['specs'][:id], :first => true) do |rec, acc|
  acc.collect! {|s| "UNC#{s}"}
  Logging.mdc['record_id'] = acc.first
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
######
to_field 'institution', literal('unc')

################################################
# Resource type
######
to_field 'resource_type', resource_type

################################################
# Virtual collection
######
to_field 'virtual_collection', extract_marc(settings['specs'][:virtual_collection], :separator => nil)

################################################
# Names
###

to_field 'names', names

def process_donor_marc(rec)
  donors = []
  Traject::MarcExtractor.cached('790|1 |abcdgqu:791|2 |abcdfg', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
    if field.tag == '790'
      included_sfs = %w[a b c d g q u]
      value = []
      field.subfields.each { |sf| value << sf.value if included_sfs.include?(sf.code) }
      value = value.join(' ').chomp(',')
      donors << {'value' => "Donated by #{value}"}
    else field.tag == '791'
      included_sfs = %w[a b c d f g]
      value = []
      field.subfields.each { |sf| value << sf.value if included_sfs.include?(sf.code) }
      value = value.join(' ').chomp(',')
      donors << {'value' => "Purchased using funds from the #{field.value}"}
    end
  end
  return donors
end

################################################
# donor
######
to_field 'donor' do |rec, acc|
  donors = process_donor_marc(rec)
  donors.each { |d| acc << d } if donors.size > 0
end

################################################
# note_local
######
to_field "note_local", note_local

each_record do |rec, context|
  donors = process_donor_marc(rec)
  if donors.size > 0
    context.output_hash['note_local'] ||= []
    donors.each { |d| context.output_hash['note_local'] << d }
  end
end


################################################
# oclc_number, sersol_number, rollup_id
# 001, 003, 035
######\
each_record do |rec, cxt|
  rollup_related_ids(rec, cxt)
end

################################################
# URLs
######
each_record do |rec, cxt|
  url_unc(rec, cxt)
end

################################################
# Items
# https://github.com/trln/extract_marcxml_for_argot_unc/blob/master/attached_record_data_mapping.csv
######
def status_map
  @status_map ||=Traject::TranslationMap.new('unc/status_map')
end

def loc_hierarchy_map
  @loc_hierarchy_map ||=Traject::TranslationMap.new('unc/loc_b_to_hierarchy')
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
  # This unless logic added because staff put print items on DWS e-records sometimes
  #   and we need to ignore those
  unless ctx.clipboard[:shared_record_set] == 'dws'

    formats = marc_formats.call(rec, [])
    items = []
    barcodes = []
    
    Traject::MarcExtractor.cached('999|*1|cdilnpqsv', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|

      item = {}
      public_notes = []

      field.subfields.each do |subfield|
        sf = subfield.code
        subfield.value.gsub!(/\|./, ' ') #remove subfield delimiters and
        subfield.value.strip! #delete leading/trailing spaces
        case sf
        when 'b'
          barcodes << subfield.value
        when 'c'
          item['copy_no'] = 'c. ' + subfield.value if subfield.value != '1'
        when 'd'
          item['due_date'] = subfield.value
        when 'i'
          item['item_id'] = subfield.value
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
      map_call_numbers!(ctx, items)

      #set location facet values
      ilocs = items.collect { |it| it['loc_b'] }
      hier_loc_code_strings = ilocs.collect { |loc| loc_hierarchy_map[loc] }.flatten
      clean_loc_strings = hier_loc_code_strings.select { |e| e.nil? == false }
      if clean_loc_strings.size > 0
        ctx.output_hash['location_hierarchy'] = explode_hierarchical_strings(clean_loc_strings)
      end

      #set barcodes field
      ctx.output_hash['barcodes'] = barcodes
    end
  end 
end

################################################
# Holdings
######

each_record do |rec, cxt|
  holdings(rec, cxt)

  # Add and manipulate fields for TRLN shared records
  case cxt.clipboard[:shared_record_set]
  when 'dws'
    add_institutions(cxt, ['duke', 'nccu', 'ncsu'])
    add_record_data_source(cxt, 'Shared Records')
    add_record_data_source(cxt, 'DWS')
    add_virtual_collection(cxt, 'TRLN Shared Records. Documents without shelves.')
  when 'oupp'
    add_institutions(cxt, ['duke', 'nccu', 'ncsu'])
    add_record_data_source(cxt, 'Shared Records')
    add_record_data_source(cxt, 'OUPP')
    add_virtual_collection(cxt, 'TRLN Shared Records. Oxford University Press print titles.')
  when 'asp'
    cxt.output_hash['institution'] << 'duke'
    add_record_data_source(cxt, 'Shared Records')
    add_record_data_source(cxt, 'ASP')
    add_virtual_collection(cxt, 'TRLN Shared Records. Alexander Street Press videos.')
    ar = cxt.output_hash['note_access_restrictions']
    ar.map{ |e| e.gsub!('UNC Chapel Hill-', '') } if ar
  end

  remove_print_from_archival_material(cxt)

  Logging.mdc.clear
end
