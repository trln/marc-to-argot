require 'set'
extend MarcToArgot::Macros::NCSU

################################################
# Primary ID
######
to_field 'id', extract_marc(settings['specs'][:id], first: true) do |_rec, acc|
  acc.collect! { |s| "NCSU#{s}" }
end

################################################
# Local ID
# rubocop:disable LineLength
to_field 'local_id', extract_marc(settings['specs'][:id], first: true) do |_rec, acc|
  acc.map! { |x| { value: x, other: [] } }
end

to_field 'institution', literal('ncsu')

to_field 'rollup_id', ncsu_rollup_id

################################################
# Items
######
item_map = {
  i: { key: 'item_id' },
  c: { key: 'copy_no' },
  m: { key: 'loc_b' },
  o: { key: 'notes' },
  a: { key: 'call_no' },
  k: { key: 'loc_current' },
  l: { key: 'loc_n' },
  t: { key: 'type' },
  v: { key: 'vol' },
  w: { key: 'cn_scheme' },
  z: { key: 'item_cat_2' }
}

def get_location(item)
  [item['loc_b'], item['loc_n']]
end

MAINS = Set.new(%w[DHILL HUNT])

def remap_item_locations!(item)
  lib, loc = get_location(item)
  if 'BOOKBOT' == lib
    item['loc_b'] = 'HUNT'
    item['loc_n'] = 'BOOKBOT' if loc == 'STACKS'
  end
  if loc == 'TEXTBOOK'
    item['loc_b'] = 'TEXTBOOK' if MAINS.include?(lib)
  end
  item['loc_b'] = 'BBR'      if 'PRINTDDA' == loc && 'DHHILL' == lib
  item['loc_b'] = 'GAME'     if 'FLOATGAME' == loc
  item['loc_b'] = 'DVD'      if 'FLOATDVD' == loc
  item['loc_b'] = 'PRAGUE'   if 'PRAGUE' == loc
  item['loc_b'] = "SPECCOLL-#{loc}" if 'SPECCOLL' == lib

  # now some remappings based on item type
  item['loc_b'] = 'GAME' if 'GAME-4HR' == item['type']
end

LOCATION_AVAILABILITY = {
  'CHECKEDOUT' => 'Checked Out',
  'ILL' => 'Checked Out',
  'ON-ORDER' => 'On Order',
  'INPROCESS' => 'Received - In Process',
  'RESERVES' => 'Available - On Reserve',
  'INTRANSIT' => 'Being transferred between libraries',
  'BINDERY' => 'Material at the bindery',
  'REPAIR' => 'Being fixed/mended',
  'PRESERV' => 'Preservation',
  'RESHELVING' => 'Just retruned',
  'CATALOGING' => 'In Process'
}

# rubocop:disable MethodLength
def library_use_only?(item)
  lib, loc = get_location(item)
  lib_cases = lib == 'SPECCOLL'
  loc_cases = case loc
              when 'GAMELAB', 'VRSTUDIO', /^SPEC/
                true
              else
                false
              end
  type_cases = case item['type']
               when 'BOOKNOCIRC', 'SERIAL', 'MAP', 'CD-ROM-NC'
                 true
               else
                 false
               end
  lib_cases || loc_cases || type_cases
end

def item_status(current, home)
  return 'Available' if current.nil? || current.empty? || current == home
  LOCATION_AVAILABILITY.fetch(
    current,
    case current
    when /^RSRV/
      'Available - On Reserve'
    else
      "Unknown - #{current}"
    end
  )
end

# ru#bocop:disable Metrics/BlockLength
to_field 'items' do |rec, acc, ctx|
  items = []
  Traject::MarcExtractor.cached('999', alternate_script: false).each_matching_line(rec) do |field, _s, _e|
    item = {}
    field.subfields.each do |subfield|
      code = subfield.code.to_sym
      mapped = item_map.fetch(code, key: nil)[:key]
      item[mapped] = subfield.value unless mapped.nil?
    end
    # $k is only present if current != home
    # needs refinement for reserves etc. and non-lending items
    current = item.fetch('loc_current', '')
    home = item.fetch('loc_n', '')
    cn_scheme = item.fetch('cn_scheme', '')
    item['status'] = item_status(current, home)
    remap_item_locations!(item)
    if library_use_only?(item)
      item['status'] << ' (Library use only)' unless item['status'] =~ /library use only/i
    end
    item.delete('item_cat_2')
    items << item
    acc << item.to_json if item
  end
  ctx.output_hash['location_hierarchy'] = arrays_to_hierarchy(items.map { |x| ['ncsu', x['loc_b']] } )
  map_call_numbers(ctx, items)
end
