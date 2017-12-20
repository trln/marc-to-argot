require 'set'

module MarcToArgot
  module Macros
    # Shared macros for TRLN institutions.  Default implementations are
    # defined here, and overriden in institution-specific modules in the
    # same namespace.
    module Shared
      # values to look for in the 856 that indicate
      # a record has online access.
      ELOC_IND2 = Set.new(%w[0 1])

      # tests whether the record has an 856[ind2] that matches
      # any of the values in ELOC_IND2
      # @param rec [MARC::Record] the record to be checked.
      # @param _ctx [Object] extra context or data to be used in the test
      #   (for overrides)
      def online_access?(rec, _ctx = {})
        l = rec.fields('856')
        return false if l.nil?
        !l.find { |f| ELOC_IND2.include?(f.indicator2) }.nil?
      end

      # tests whether the record has any physical items
      # this implementation asks whether there are any 999 fields.
      # @param rec [MARC::Record] the record to be checked.
      # @param _ctx [Object] extra context or data to be used in the test
      #   (for overrides)
      def physical_access?(rec, _ctx = {})
        !rec['999'].nil?
      end

      # accumulates an array of JSON Blobs with URL data from a record.
      def url
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("856uy3").each_matching_line(rec) do |field, spec, extractor|
            url = {}
            url[:href] = collect_subfield_values_by_code(field, 'u').first

            next if url[:href].nil? || url[:href].empty?

            url[:type] = url_type_value(field)
            url[:text] = url_text(field) unless url_text(field).empty?

            acc << url.to_json
          end
        end
      end

      # returns a type value based on the 856 field's 2nd indicator value
      # @param field [MARC::DataField] the field to use to assign a type value
      def url_type_value(field)
        case field.indicator2
        when '0'
          type = 'fulltext'
        when '1'
          type = 'fulltext'
        when '2'
          type = 'related'
        else
          type = 'other'
        end

        if url_for_thumbnail?(field)
          type = 'thumbnail'
        end

        if url_for_finding_aid?(field)
          type = 'findingaid'
        end

        type
      end

      # tests whether the field contains a URL for a thumbnail
      # @param field [MARC::DataField] the field to check for a thumbnail URL
      def url_for_thumbnail?(field)
        substring_present_in_subfield?(field, '3', 'thumbnail')
      end

      # tests whether the field contains a URL for a finding aid
      # @param field [MARC::DataField] the field to check for a finding aid URL
      def url_for_finding_aid?(field)
        substring_present_in_subfield?(field, '3', 'finding aid')
      end

      # assembles a string from the 856 subfields 3 & y to use for the URL text
      # @param field [MARC::DataField] the field to use to assemble URL text
      def url_text(field)
        subfield_values_3 = collect_subfield_values_by_code(field, '3')
        subfield_values_y = collect_subfield_values_by_code(field, 'y')
        ([subfield_values_3.join(' ')] + [subfield_values_y.join(' ')]).reject(&:empty?).join(' -- ')
      end

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
        field.subfields.collect {|sf| sf.value if sf.code == code}.compact
      end
    end
  end
end
