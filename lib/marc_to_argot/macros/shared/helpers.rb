module MarcToArgot
  module Macros
    module Shared
      module Helpers

        ################################################################
        # general helpers
        ################################################################

        # tests whether a field's subfields with a particular code
        # contain any instance of a substring
        # @param field [MARC::DataField] the field to check for a subfield substring
        # @param code [String] the code for the subfields to check
        # @param substring [String] the substring to test for presence
        def substring_present_in_subfield?(field, code, substring)
          subfield_values = collect_subfield_values_by_code(field, code)
          subfield_values.collect { |sy| sy.downcase.include?(substring) }.any?
        end

        # collects an array of values from all instances of a particular subfield
        # code from a field
        # @param field [MARC::DataField] the field to collect subfields from
        # @param code [String] the code of the subfield to collect
        def collect_subfield_values_by_code(field, code)
          field.subfields.collect { |sf| sf.value if sf.code == code }.compact
        end
      end
    end
  end
end
