$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), './../../lib'))

require 'time'

# To have access to various built-in logic
# for pulling things out of MARC21, like `marc_languages`
require 'traject/macros/marc21_semantics'
extend  Traject::Macros::Marc21Semantics

# To have access to the traject marc format/carrier classifier
require 'traject/macros/marc_format_classifier'
extend Traject::Macros::MarcFormats

require 'argot_semantics'
extend Traject::Macros::ArgotSemantics

require 'yaml'
require 'library_stdnums'

require 'spec_generator'
require 'argot_writer'

if settings["spec_file"]
  spec_config = SpecGenerator::generate_spec_file(settings["spec_file"])
else
  spec_config = SpecGenerator::generate_spec_file(File.join(File.dirname(__FILE__), "specs.yml"))
end

settings do

  # Spec configurations, you should not need to adjust this
  provide "specs", spec_config

  # threads
  provide 'processing_thread_pool', 3

  # default output file (placed into the directory where you run the script)
  provide "output_file", "~/argot_out.json"
  
  # set to true for pretty JSON output
  provide "argot_writer.pretty_print", false

  # Comment out/remove if using marc binary
  provide "marc_source.type", "xml"

  # Prevent argot.rb from processing these fields (you will need to provide your own logic)
  provide "override", %w(id local_id institution cataloged_date items)

end

################################################
# Primary ID
######
to_field "id", extract_marc(settings["specs"][:id], :first => true) do |rec, acc|
  acc.collect! {|s| "UNC#{s.delete("b.")}"}
end

################################################
# Local ID
######
to_field "local_id" do |rec, acc|
  primary = Traject::MarcExtractor.cached("907a").extract(rec).first
  primary = primary.delete(".") if primary

  local_id = {
    :value => primary,
    :other => []
  }

  # do things here for "Other"

  acc << local_id
end

################################################
# Institutiuon
######\
to_field "institution", literal("unc")

################################################
# Catalog Date
######

to_field "cataloged_date" do |rec, acc|
  cataloged = Traject::MarcExtractor.cached("909").extract(rec).first
  acc << Time.parse(cataloged).utc.iso8601 if cataloged
end

################################################
# Items
# https://github.com/trln/extract_marcxml_for_argot_unc/blob/master/attached_record_data_mapping.csv
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
    :key => "call_number_tag",
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
    if field.indicator2 == "1"
      item = Hash.new
      class_number = false

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
          #remove vertical pipe-codes in call number
          if code == :q
            subfield.value = subfield.value.gsub(/\|[a-z]/,' ')
            subfield.value = subfield.value.strip
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
    end

    if class_number and class_number == "090"
      item["lcc_top"] = [item["call_number"].first[0,1]]
    end

    acc << item.each_key {|x| item[x] = item[x].join(';')  } if item

  end
end
