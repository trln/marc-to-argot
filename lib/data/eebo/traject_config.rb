################################################
# Primary ID
######
to_field 'id', extract_marc('001', first: true) do |rec, acc|
  acc.collect! do |s|
	s.gsub(/^\D*/,'').gsub(/[^0-9e]$/,'')
  end
  acc.collect! { |s| "EEBO#{s}" }
  Logging.mdc['record_id'] = acc.first
end

to_field 'names', names


################################################
# Local ID

to_field 'local_id', extract_marc(settings['specs'][:id], first: true) do |_rec, acc|
  acc.map! { |x| { value: x, other: [] } }
end

to_field 'institution' do |rec, acc| 
	acc << %w[ncsu unc duke]
	acc.flatten!
end	


to_field 'rollup_id', rollup_id

to_field 'resource_type', literal("Book")

to_field 'record_data_source' do |rec,acc| 
	["MARC", "Shared Records" , "EEBO"].each {|i| acc<<i}
end

to_field 'url', extract_marc('856u', first: true) do |_rec, acc|
  acc.map! do |u|
   {"href"=>"{+proxyPrefix}#{u}",
   "text"=>"View resource online",
   "type"=>"fulltext"}.to_json
   
  end
end


each_record do |rec, ctx|
  
  Logging.mdc.clear
end
