module MarcToArgot
  module Macros
    # Macros and useful functions for UNC records
    module UNC
      require 'marc_to_argot/macros/unc/local_subject_genre'
      require 'marc_to_argot/macros/unc/finding_aid'
      require 'marc_to_argot/macros/unc/holdings'
      require 'marc_to_argot/macros/unc/items'
      require 'marc_to_argot/macros/unc/resource_type'
      require 'marc_to_argot/macros/unc/rollup'
      require 'marc_to_argot/macros/unc/shared_records'
      require 'marc_to_argot/macros/unc/urls'
      
      include Traject::Macros::Marc21Semantics
      include MarcToArgot::Macros::Shared

      include LocalSubjectGenre
      include FindingAid
      include Holdings
      include Items
      include ResourceType
      include Rollup
      include SharedRecords
      include Urls

      MarcExtractor = Traject::MarcExtractor
      
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

    end
  end
end
