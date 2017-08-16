# Traject
require 'traject'
require 'traject/macros/marc21_semantics'
require 'traject/macros/marc_format_classifier'
require 'marc'

# Argot
require 'traject/argot_semantics'
require 'traject/argot_writer'

# Other Helpers

require 'library_stdnums'
require 'thor'
require 'json'
require 'yaml'
require 'time'

# Top-level module for conversion to Argot
module MarcToArgot
  autoload :VERSION, 'marc_to_argot/version'
  autoload :CommandLine, 'marc_to_argot/command_line'
  autoload :SpecGenerator, 'marc_to_argot/spec_generator'
  autoload :CallNumbers, 'marc_to_argot/call_numbers'
end
