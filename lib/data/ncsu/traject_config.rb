################################################
# Primary ID
######
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

def shadowed_location?(item)
  %w[BOTMISSING ACQ-S MISSING].include?(item['loc_n'])
end

each_record do |rec, ctx|
  items = ctx.clipboard['items']
  items.reject! { |i| shadowed_location?(i) }
  urls = ctx.output_hash.fetch('url', [])
  open_access!(urls, items)
  items.each { |i| i.delete('item_cat_2') }
  logger.info "Skipping #{ctx.output_hash['id']} (no items)" if items.empty?
  ctx.skip! if items.empty?
  if serial?(rec)
    libraries = items.map { |i| i['loc_b'] }.uniq
    
    if online_access?(rec, libraries)
      loc_id = ctx.output_hash['local_id'].first[:value]
      href = "https://www.lib.ncsu.edu/journals/more_info.php?catkey=#{loc_id}"
      urls << { type: 'fulltext', href: href, text: 'View online access'}.to_json
    else
      title_esc = URI.escape(ctx.output_hash['title_main'].first[:value])
      href= "https://www.lib.ncsu.edu/journals/search.php?type=keywords&search=#{title_esc}"
      urls << { type: 'other', href: href, text: 'Search for online access' }.to_json
    end
    ctx.output_hash['url'] = urls
  end

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
