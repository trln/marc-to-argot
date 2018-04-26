module MarcToArgot
  module Macros
    # Macros and useful functions for Duke records
    module Duke
      include MarcToArgot::Macros::Shared

      # Sets the list of MARC org codes that are local.
      # Used by #subfield_5_present_with_local_code?
      def local_marc_org_codes
        %w[NcD NcD-B NcD-D NcD-L NcD-M NcD-W NcDurDH]
      end

      # Check for physical item record returns true unless it
      # has an 856 where the first indicator is 0.
      def physical_access?(rec, _ctx = {})
        l = rec.fields('856')
        return false if !l.find { |f| ['0'].include?(f.indicator2) }.nil?
        true
      end

      # tests whether the field contains a URL for a finding aid
      # @param field [MARC::DataField] the field to check for a finding aid URL
      def url_for_finding_aid?(field)
        substring_present_in_subfield?(field, 'y', 'collection guide')
      end

      class PhysicalMedia::PhysicalMediaClassifier
        # Checks the 940$c for any cases where the narrow location
        # includes an ebook location code. See #ebook_location_codes below.
        def e_reader?
          item_fields(record).find do |field|
            field.subfields.select { |sf| sf.code == 'c' }.find { |sfc| ebook_location_codes.include?(sfc.value) }
          end
        end

        # Checks the 940$h for call numbers that include the
        # substring "kindle."
        def e_reader_kindle?
          item_fields(record).find do |field|
            field.subfields.select { |sf| sf.code == 'h' }.find { |sfc| sfc.value.downcase.include?('kindle') }
          end
        end

        def item_fields(record)
          @item_fields ||= begin
            item_fields = []
            Traject::MarcExtractor.cached('940', alternate_script: false).each_matching_line(record) do |field|
              item_fields << field
            end
            item_fields
          end
        end

        def ebook_location_codes
          %w[DKK FRDK1 FRDK2 FRDK3 PDK PKKI PKKR PKKZ
             PKXKR PLK1 PLK2 PLKR PLXKR PZK1 PZK2]
        end
      end

      # # Example of how to re-open the ResourceTypeClassifier
      # # You can add to or completely override the formats method as needed.
      # # You can also override the default classifying methods e.g. book?
      # # If none of this works for you just override
      # # MarcToArgot::Macros::Shared.resource_type in your local macros.
      #
      # class ResourceType::ResourceTypeClassifier
      #   alias_method :default_formats, :formats
      #   alias_method :default_audiobook, :audiobook

      #   def formats
      #     formats = []
      #     formats.concat default_formats
      #     formats << 'Dapper squirrel' if dapper_squirrel?
      #   end

      #   # Override default book classifying method
      #   def book?
      #     false
      #   end

      #   # Override default audio_book classifier but
      #   # use aliased copy of original method as part of criteria.
      #   def audiobook?
      #     default_audiobook || record.leader.byteslice(6) == '*'
      #   end

      #   # Add a new classifying method and add it to your local formats methods
      #   def dapper_squirrel?
      #     true
      #   end
      # end
    end
  end
end
