to_field 'id', extract_marc(settings['specs'][:id], first: true) do |_rec, acc|
 acc.collect! { |s| "NCCU#{s}" }
 Logging.mdc['record_id'] = acc.first
end

################################################
# Local ID

to_field 'local_id', extract_marc(settings['specs'][:id], first: true) do |_rec, acc|
  acc.map! { |x| { value: x, other: [] } }
end

to_field 'institution', literal('nccu')

to_field 'items', extract_items

to_field 'rollup_id', rollup_id

to_field 'names', names

to_field 'primary_oclc', primary_oclc



each_record do |rec, ctx|
  access_type = ctx.output_hash['access_type']
  if access_type
    physical_media = ctx.output_hash['physical_media']
    if physical_media
      physical_media << 'Online' if access_type.include?('Online')
    else
      ctx.output_hash['physical_media'] = ['Online'] if access_type.include?('Online')
    end
  end

  remove_print_from_archival_material(ctx)

  Logging.mdc.clear
end
