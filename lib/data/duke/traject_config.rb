################################################
# Add shared record info to clipboard
# if applicable
######

each_record do |rec, cxt|
  set_shared_record_set_code(rec, cxt)
end

################################################
# Primary ID
######
to_field 'id', extract_marc(settings['specs'][:id], first: true) do |rec, acc|
  acc.collect! do |s|
    id = s.to_s.strip
    id.match(/DUKE.*/) ? id : "DUKE#{id}"
  end
  Logging.mdc['record_id'] = acc.first
end

################################################
# Local ID
######

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
# OCLC Number
######

to_field "oclc_number", oclc_number

################################################
# Serials Solutions Number
######

to_field 'sersol_number', sersol_number

################################################
# Rollup ID
######

to_field "rollup_id", rollup_id

################################################
# Institutiuon
######
to_field 'institution', literal('duke')

##################
# Names
#########
to_field 'names', names

##################
# Bookplate
#########
to_field 'bookplate', extract_marc("796z")


# ################################################
# # Items
# ######

to_field 'items', extract_items


# ################################################
# # Holdings
# ######

to_field 'holdings', extract_holdings

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
# # Notes -- Duke Specific
# ######

to_field 'note_use_terms', note_use_terms

# ################################################
# # Final each_record block
# ######

each_record do |rec, ctx|
  remove_print_from_archival_material(ctx)
  add_bookplate_to_notes_local(ctx)

  # Remove Rollup ID from special collections records
  # Otherwise set rollup id to SerSol number if not already set.
  if ctx.clipboard.fetch('special_collections', false)
    ctx.output_hash.delete('rollup_id')
  else
    set_sersol_rollup_id(ctx)
  end

  # Set Availability and Physical Media for Online resources.
  if ctx.output_hash.fetch('access_type', []).include?('Online')
    ctx.output_hash['available'] = 'Available'
    physical_media = ctx.output_hash.fetch('physical_media', [])
    ctx.output_hash['physical_media'] = physical_media << 'Online'
    if ctx.output_hash.fetch('access_type', []) == ['Online']
      ctx.output_hash['physical_media'].delete('Print')
    end
  end

  add_shared_record_data(ctx) if ctx.clipboard.fetch(:shared_record_set, false)
  Logging.mdc.clear
end
