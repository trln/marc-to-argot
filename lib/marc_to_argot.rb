# Logging
require 'yell'
require 'yell/logging_adapter'

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
require 'ext/marc/data_field'
require 'ext/marc/control_field'
require 'ext/marc/record'

# Top-level module for conversion to Argot
module MarcToArgot
  autoload :VERSION, 'marc_to_argot/version'
  autoload :CommandLine, 'marc_to_argot/command_line'
  autoload :SpecGenerator, 'marc_to_argot/spec_generator'
  autoload :CallNumbers, 'marc_to_argot/call_numbers'
  autoload :Macros, 'marc_to_argot/macros'
  autoload :Indexers, 'marc_to_argot/indexers'
  autoload :Util, 'marc_to_argot/util'
end
