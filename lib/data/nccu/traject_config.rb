to_field 'id', extract_marc(settings['specs'][:id], first: true) do |_rec, acc|
 acc.collect! { |s| "NCCU#{s}" }
end

################################################
# Local ID

to_field 'local_id', extract_marc(settings['specs'][:id], first: true) do |_rec, acc|
  acc.map! { |x| { value: x, other: [] } }
end

to_field 'institution', literal('nccu')

to_field 'items', extract_items

to_field 'rollup_id', rollup_id