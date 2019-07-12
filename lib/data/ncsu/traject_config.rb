################################################
# Primary ID
######
#
count = 0
skips = 0
last_id_seen = '<none>'

each_record do |_|
  count += 1
end

to_field 'id', extract_marc('918a', first: true) do |rec, acc|
  acc.collect! { |s| "NCSU#{s}" }
  Logging.mdc['record_id'] = acc.first
end

to_field 'names', names

################################################
# Local ID

to_field 'local_id', extract_marc(settings['specs'][:id], first: true) do |_rec, acc|
  acc.map! { |x| { value: x, other: [] } }
end

to_field 'institution', literal('ncsu')

to_field 'rollup_id', rollup_id

to_field 'items', extract_items

to_field 'physical_media', physical_media

to_field 'resource_type', resource_type

to_field 'sersol_number', sersol_number

to_field 'donor', donor

to_field 'issn', ncsu_issn(settings['specs'][:issn])

each_record do |rec, ctx|
  last_id_seen = ctx.output_hash['id']
  items = ctx.clipboard['items']
  urls = ctx.output_hash.fetch('url', []).map { |u| JSON.parse(u) }
  open_access!(urls, items)
  items.each { |i| i.delete('item_cat_2') }
  if items.empty?
    logger.info "Skipping #{ctx.output_hash['id']} (no items)"
    skips += 1
    ctx.skip!
  end
  #handle trln videos
  process_shared_records!(rec, ctx, urls)
  if serial?(rec)
    # throw out any catalogued URLs for serials, instead prefer
    # journals link
    if local?(ctx)
      urls = ctx.output_hash['url'] = []
    end

    libraries = items.map { |i| i['loc_b'] }.uniq
    loc_id = ctx.output_hash['local_id'].first[:value]
    href = "https://www.lib.ncsu.edu/journals/more_info.php?catkey=#{loc_id}"
    if online_access?(rec, libraries)
      urls << { type: 'fulltext', href: href, text: 'View available online access'}
    else
      # rely on matched records on catkey for link
      urls << { type: 'other', href: href, text: 'Search for online access' }
    end
  end
  ctx.output_hash['url'] = urls.map(&:to_json)

  ctx.output_hash['barcodes'] = items.map { |x| x['item_id'] }.select(&:itself)
  ctx.output_hash['available'] = 'Available' if is_available?(items)
  if ctx.output_hash.fetch('format', []).include?('Journal/Newspaper')
    holdings = generate_holdings(items)
    ctx.output_hash['holdings'] = holdings.map(&:to_json)
  end

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

  set_sersol_rollup_id(ctx)

  Logging.mdc.clear
end

after_processing do
  logger.info "I saw #{count} records in total, skipped #{skips}; last seen was #{last_id_seen}"
end
