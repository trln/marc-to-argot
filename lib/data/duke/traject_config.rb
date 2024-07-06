################################################
# Primary ID
######
to_field 'id', extract_marc(settings['specs'][:id], first: true) do |rec, acc|
  acc.collect! do |s|
    id = s.to_s.strip

    # "scan" will attempt to match the MMS id string by a 
    # pattern we "believe" represents all Aleph-born records 
    # migrated into Alma
    #
    # If we do match (and you'll see this below), the 3rd element of our
    # capture will hold the old-style Aleph 'sysid'
    # mms_splits = id.scan(/^(DUKE)?(\d{2})(\d{9})(\d{7})/)

    mms_splits = id.scan(/^(DUKE)?(99)(\d{9})(0108501)/)

    # If the split result is empty, this represents a new Alma-born record
    # Otherwise, get the old Aleph id from the split string.
    # -
    # We'll maintain the entire MMS ID string
    id = mms_splits.empty? ? id : mms_splits[0][2]
    id.match(/DUKE.*/) ? id : "DUKE#{id}"
  end
  Logging.mdc['record_id'] = acc.first
end

################################################
# Local ID
######

# NOTE is this where we set 'local_id' to the MMS ID?
to_field 'local_id' do |rec, acc, context|
  local_id = {
    value: context.output_hash.fetch('id', []).first,
    other: []
  }

  acc << local_id
end

################################################
# URL handling (also for shared records)
######
to_field "url", url

################################################
# Title variant handling (also for shared records)
######

to_field 'title_variant', title_variant

################################################
# OCLC Number
######

to_field "oclc_number", oclc_number

################################################
# MMS ID
######

to_field "mms_id", extract_marc('001')

################################################
# Serials Solutions Number
######

to_field 'sersol_number', sersol_number

################################################
# Rollup ID
######

to_field "rollup_id", rollup_id

################################################
# Primary OCLC
######

to_field "primary_oclc", primary_oclc

################################################
# Internet Archive ID
######

to_field "internet_archive_id", extract_marc('955q')

################################################
# Institutiuon
######

to_field 'institution', literal('duke')

##################
# Names
#########

to_field 'names', names

##################
# Donor
#########
to_field 'donor', extract_marc("796z")

# ################################################
# # Holdings
# ######

to_field 'holdings', extract_holdings

# ################################################
# # Items
# ######

to_field 'items', extract_items

#to_field 'holding_summaries', extract_holding_summaries

# ################################################
# # Physical Media
# ######


to_field 'physical_media' do |rec, acc, ctx|
  if physical_access?(rec, ctx)
    acc.concat PhysicalMediaClassifier.new(rec).media
  end
end

# ################################################
# # Access Type
# ######

to_field 'access_type' do |rec, acc, ctx|
  acc << 'Online' if online_access?(rec)
  acc << 'At the Library' if physical_access?(rec, ctx)
end

# ################################################
# # Date Cataloged
# ######

to_field 'date_cataloged' do |rec, acc|
  cataloged = Traject::MarcExtractor.cached(settings['specs'][:date_cataloged])
                                    .extract(rec).first.to_s.strip
  begin
    acc << Time.parse(cataloged).utc.iso8601 if cataloged =~ /\A?[0-9]*\.?[0-9]+\Z/
  rescue ArgumentError => e
    Logging.mdc['field'] = settings['specs'][:date_cataloged].to_s
    logger.warn("date_cataloged value cannot be parsed: #{e}")
    Logging.mdc.delete('field')
  end
end

# ################################################
# # Final each_record block
# ######

each_record do |rec, ctx|
  index_bib_id(ctx)
  remove_print_from_archival_material(ctx)
  add_donor_to_indexed_note_local(ctx)
  add_holdings_note_to_indexed_note_local(rec, ctx)
  finalize_rollup_id(ctx)
  finalize_values_for_online_resources(ctx)
  set_entity_ids!(ctx)
  Logging.mdc.clear
end
