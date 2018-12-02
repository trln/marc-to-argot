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
# # Final each_record block
# ######

each_record do |rec, ctx|
  remove_print_from_archival_material(ctx)
  add_bookplate_to_notes_local(ctx)
  if ctx.clipboard.fetch('special_collections', false)
    ctx.output_hash.delete('rollup_id')
  else
    set_sersol_rollup_id(ctx)
  end
  Logging.mdc.clear
end
