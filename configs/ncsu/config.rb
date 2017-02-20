$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), './../../lib'))

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
  provide "override", %w(id institution items)

end

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

    acc << item.each_key {|x| item[x] = item[x].join(';')  } if item

  end
end
