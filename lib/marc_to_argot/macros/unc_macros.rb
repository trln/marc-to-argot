module MarcToArgot
  module Macros
    # Macros and useful functions for UNC records
    module UNC
      MarcExtractor = Traject::MarcExtractor
      include Traject::Macros::Marc21Semantics
      include MarcToArgot::Macros::Shared

      # Sets the list of MARC org codes that are local.
      # Used by #subfield_5_present_with_local_code?
      def local_marc_org_codes
        %w[NcU NcU-BPR NcU-H NcU-IG NcU-LL NcU-LS NcU-MS NcU-Mu NcU-Pop]
      end

      # tests whether the record has any physical items
      # this implementation asks whether there are any 999 fields that:
      #  - have i1=9 (in all records, dates are output to 999 w/i1=0), and
      #  - have i2<3 (i.e. an unsuppressed item or holding record exists)
      # Records with ONLY an order record will NOT be assigned an
      #  access_type value, given that it is presumed the item is on order
      #  and not at all accessible yet.
      # @param rec [MARC::Record] the record to be checked.
      # @param _ctx [Object] extra context or data to be used in the test
      #   (for overrides)
      def physical_access?(rec, _ctx = {})
        checkfields = []
        rec.each_by_tag('999') { |f| checkfields << f if f.indicator1 == '9' && f.indicator2.to_i < 3}
        if checkfields.size > 0
          return true
        else
          return false
        end
      end

      # assembles a string from the 856 subfields 3 & y to use for the URL text
      # @param field [MARC::DataField] the field to use to assemble URL text
      def url_text(field)
        subfield_values_3 = collect_subfield_values_by_code(field, '3').map { |val| val.strip.sub(/ ?\W* ?$/, '')}
        subfield_values_y = collect_subfield_values_by_code(field, 'y').map { |val| val.strip }

        if subfield_values_y.empty? && url_type_value(field) == 'fulltext'
          subfield_values_y << 'Available via the UNC-Chapel Hill Libraries'
        end

        ([subfield_values_3.join(' ')] + [subfield_values_y.join(' ')]).reject(&:empty?).join(' -- ')
      end
    end
  end
end
