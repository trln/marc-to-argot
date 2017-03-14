################################################
# Primary ID
######
to_field "id", extract_marc(settings["specs"][:id], :first => true) do |rec, acc|
  acc.collect! {|s| "NCSU#{s}"}
end


################################################
# Local ID
######

################################################
# Institutiuon
######
to_field "institution", literal("ncsu")

################################################
# Catalog Date
######

################################################
# Items
######
item_map = {
  :i => {
    :key => "barcode"
  },
  :c => {
    :key => "copy_number",
  },
  :m => {
    :key => "location",
  },
  :o => {
    :key => "note",
  },
  :a => {
    :key => "call_number",
  },
  :k => {
    :key => "status",
  },
  :t => {
    :key => "type",
  },
  :v => {
    :key => "volume",
  },
  :w => {
    :key => "call_number_scheme"
  }
}

to_field "items" do |rec, acc|

  Traject::MarcExtractor.cached("999", :alternate_script => false).each_matching_line(rec) do |field, spec, extractor|
    item = {}

    field.subfields.each do |subfield|
      code = subfield.code.to_sym
      if item_map.key?(code)
        if !item.key?(code)
            item[item_map[code][:key]] = []
        end
        
        item[item_map[code][:key]] << subfield.value
        if code == :i
          if !item["ils_number"].is_a?(Array)
            item["ils_number"] = []
          end
          item["ils_number"] << subfield.value
        end

        if item_map[code][:translation_map]
          translation_map = Traject::TranslationMap.new(item_map[code][:translation_map])
          translation_map.translate_array!(item[item_map[code][:key]])
        end
      end
    end

    if item["call_number_scheme"] and item["call_number_scheme"].first == "LC"
      item["lcc_top"] = [item["call_number"].first[0,1]]
    end

    acc << item.each_key {|x| item[x] = item[x].join(';')  } if item

  end
end
