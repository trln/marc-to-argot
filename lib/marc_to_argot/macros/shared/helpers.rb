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

        # collects an array of values from all instances of one or more subfields
        # and joins those values with the specified separator
        # @param field [MARC::DataField] the field to collect subfields from
        # @param code [String]|[Array] the code(s) of the subfield to collect
        # @param separator [String] the string to use to join the values
        def collect_and_join_subfield_values(field, subfields_spec, separator = ' ')
          field.subfields.select { |sf| [*subfields_spec].include?(sf.code) }.map(&:value).join(separator)
        end
      end
    end
  end
end
