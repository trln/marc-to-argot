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
      require 'marc_to_argot/macros/unc/call_number'
      require 'marc_to_argot/macros/unc/dummy_items'
      require 'marc_to_argot/macros/unc/location_hierarchy'
      require 'marc_to_argot/macros/unc/available'

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
      include CallNumber
      include DummyItems
      include LocationHierarchy
      include Available

      MarcExtractor = Traject::MarcExtractor

      # Sets the list of MARC org codes that are local.
      # Used by #subfield_5_present_with_local_code?
      def local_marc_org_codes
        %w[NcU NcU-BPR NcU-H NcU-IG NcU-LL NcU-LS NcU-MS NcU-Mu NcU-Pop]
      end

      # tests whether the record has any physical items
      # Because some items/holdings encoded in the marc are ignored
      # (e.g. items/holdings on e-only shared records; e-holdings records),
      # this implementation checks for the presence of items/holdings data
      # in the processed argot.
      # Records with ONLY an order record will NOT be assigned an
      #  access_type value, given that it is presumed the item is on order
      #  and not at all accessible yet.
      # @param _rec [MARC::Record] the record to be checked.
      # @param ctx [Object] extra context or data to be used in the test
      #   (for overrides)
      def physical_access?(_rec, ctx)
        return true if (ctx.output_hash.fetch('items', []).any? ||
                        ctx.output_hash.fetch('holdings', []).any?)

        false
      end

      def filmfinder?(rec)
        Traject::MarcExtractor.cached('919|  |a:', alternate_script: false).each_matching_line(rec) do |field, _spec, _extractor|
          return true if field.value.casecmp('filmfinder').zero?
        end
        false
      end

      def ncdhc?(rec)
        Traject::MarcExtractor.cached('907|  |a:', alternate_script: false).each_matching_line(rec) do |field, _spec, _extractor|
          return true if field.value.start_with?('NCDHC')
        end
        false
      end

      def process_donor_marc(rec)
        donors = []
        Traject::MarcExtractor.cached('790|0 |abcdgqu:791|2 |abcdfg', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
          if field.tag == '790'
            included_sfs = %w[a b c d g q u]
            value = []
            field.subfields.each { |sf| value << sf.value if included_sfs.include?(sf.code) }
            value = value.join(' ').chomp(',')
            if value.start_with?('From the library of')
              donors << {'value' => value}
            else
              donors << {'value' => "Donated by #{value}"}
            end
          elsif field.tag == '791'
            included_sfs = %w[a b c d f g]
            value = []
            field.subfields.each { |sf| value << sf.value if included_sfs.include?(sf.code) }
            value = value.join(' ').chomp(',')
            donors << {'value' => "Purchased using funds from the #{field.value}"}
          end
        end
        donors
      end

      def add_donors_as_indexed_only_local_notes(ctx)
        return unless ctx.output_hash.key?('donor')

        donor = ctx.output_hash['donor'].map { |d| {'indexed_value' => d['value']} }
        local_notes = ctx.output_hash.fetch('note_local', [])
        ctx.output_hash['note_local'] = local_notes.concat(donor)
      end
    end
  end
end
