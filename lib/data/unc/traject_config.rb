to_field 'id', extract_marc(settings['specs'][:id], :first => true) do |rec, acc|
  acc.collect! {|s| "UNC#{s}"}
  Logging.mdc['record_id'] = acc.first
end

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

to_field 'institution', literal('unc')

to_field 'resource_type', resource_type

# set virtual_collection from 919$t
to_field 'virtual_collection', extract_marc(settings['specs'][:virtual_collection], :separator => nil)

def process_donor_marc(rec)
  donors = []
  Traject::MarcExtractor.cached('790|0 |abcdgqu:791|2 |abcdfg', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
    if field.tag == '790'
      included_sfs = %w[a b c d g q u]
      value = []
      field.subfields.each { |sf| value << sf.value if included_sfs.include?(sf.code) }
      value = value.join(' ').chomp(',')
      if value.start_with?('From the library of')
        donors << { 'value' => value }
      else
        donors << {'value' => "Donated by #{value}"}
      end
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

to_field 'donor' do |rec, acc|
  donors = process_donor_marc(rec)
  donors.each { |d| acc << d } if donors.size > 0
end

to_field "note_local", note_local

each_record do |rec, context|
  donors = process_donor_marc(rec)
  if donors.size > 0
    context.output_hash['note_local'] ||= []
    donors.each { |d| context.output_hash['note_local'] << d }
  end
end

each_record do |rec, cxt|
  out = cxt.output_hash
  # identify shared record set members
  # this must come before URLs and shared records fields are processed
  shared_record_set = id_shared_record_set(rec)
  cxt.clipboard[:shared_record_set] = shared_record_set if shared_record_set

  # set oclc_number, sersol_number, rollup_id from 001, 003, 035
  rollup_related_ids(rec, cxt)

  # populate URL fields
  url_unc(rec, cxt)

  # set EAD id
  set_ead_id(rec, cxt)

  # unless staff have added print item/holdings to DWS shared records
  # create items and holdings
  unless cxt.clipboard[:shared_record_set] == 'dws'
    items(rec, cxt)
    holdings(rec, cxt)
  end

  process_call_numbers(rec, cxt)

  # create dummy item with "On Order" status if no items, not online, and order record exists
  # create dummy item with "Contact Library for Status" if the above, but no order record
  dummy_items(rec, cxt) if (( out['access_type'] && !out['access_type'].include?('Online') ) ||
                             out['access_type'].nil? ) &&
                           out['items'].nil? &&
                           out['holdings'].nil?

  # set location_hierarchy and available fields from real and dummy items
  location_hierarchy(rec, cxt)
  available(rec, cxt) if out['items']

  # add genre_mrc field
  local_subject_genre(rec, cxt)

  # Add and manipulate fields for TRLN shared records and other special record groups
  case cxt.clipboard[:shared_record_set]
  when 'asp'
    out['institution'] << 'duke'
    add_record_data_source(cxt, 'Shared Records')
    add_record_data_source(cxt, 'ASP')
    add_virtual_collection(cxt, 'TRLN Shared Records. Alexander Street Press videos.')
    ar = out['note_access_restrictions']
    ar.map{ |e| e.gsub!('UNC Chapel Hill-', '') } if ar
  when 'crl'
    add_institutions(cxt, ['duke', 'ncsu'])
    add_record_data_source(cxt, 'Shared Records')
    add_record_data_source(cxt, 'CRL')
    add_virtual_collection(cxt, 'TRLN Shared Records. Center for Research Libraries (CRL) e-resources.')
    ar = out['note_access_restrictions']
    ar.map{ |e| e.gsub!('UNC Chapel Hill-', '') } if ar
  when 'dws'
    add_institutions(cxt, ['duke', 'nccu', 'ncsu'])
    add_record_data_source(cxt, 'Shared Records')
    add_record_data_source(cxt, 'DWS')
    add_virtual_collection(cxt, 'TRLN Shared Records. Documents without shelves.')
  when 'filmfinder'
    # MRC's scoped FilmFinder search includes everything in MRC physical locations
    #  and everything with this virtual_collection value
    add_virtual_collection(cxt, 'UNC MRC FilmFinder online and special materials')
  when 'oupp'
    add_institutions(cxt, ['duke', 'nccu', 'ncsu'])
    add_record_data_source(cxt, 'Shared Records')
    add_record_data_source(cxt, 'OUPP')
    add_virtual_collection(cxt, 'TRLN Shared Records. Oxford University Press print titles.')
  end

  remove_print_from_archival_material(cxt)

  Logging.mdc.clear
end
