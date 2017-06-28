################################################
# Primary ID
######
to_field "id", extract_marc(settings["specs"][:id], :first => true) do |rec, acc|
  acc.collect! {|s| "#{s}"}
end

################################################
# Local ID
######

################################################
# Institutiuon
######
to_field "institution", literal("duke")

################################################
# Catalog Date
######

################################################
# Items
######
item_map = {
  :b => {
    :key => "barcode"
  },
  :c => {
    :key => "copy_number",
  },
  :d => {
    :key => "due_date",
  },
  :i => {
    :key => "ils_id",
  },
  :l => {
    :key => "location",
    #:translation_map => "unc/locations_map",
  },
  :n => {
    :key => "note",
  },
  :o => {
    :key => "checkouts",
  },
  :p => {
    :key => "call_number_scheme",
  },
  :q => {
    :key => "call_number", 
  },
  :s => {
    :key => "status",
    :translation_map => "unc/status_map"
  },
  :t => {
    :key => "type",
  },
  :v => {
    :key => "volume",
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
        # Translation map can't use a dash as a key, so change to string 'dash'
        if code == :s && subfield.value == "-"
          subfield.value = "dash"
        end
        #change dates to ISO8601
        if code == :d 
          subfield.value = Time.parse(subfield.value).utc.iso8601
        end
        #change checkouts to int
        if code == :o
          subfield.value = subfield.value.to_i
        end
        if code == :p
          class_number = subfield.value
        end
        
        item[item_map[code][:key]] << subfield.value

        if item_map[code][:translation_map]
          translation_map = Traject::TranslationMap.new(item_map[code][:translation_map])
          translation_map.translate_array!(item[item_map[code][:key]])
        end
      end
    end

    if item["call_number_scheme"] and item["call_number_scheme"].first == "0"
      item["lcc_top"] = [item["call_number"].first[0,1]]
    end

    acc << item.each_key {|x| item[x] = item[x].join(';')  } if item

  end
end
