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
  provide "override", %w(institution)

end

################################################
# Primary ID
######


################################################
# Local ID
######

################################################
# Institutiuon
######
to_field "institution", literal("nccu")

################################################
# Catalog Date
######

################################################
# Items
######
