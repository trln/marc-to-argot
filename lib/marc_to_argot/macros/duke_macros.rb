module MarcToArgot
  module Macros
    # Macros and useful functions for Duke records
    module Duke
      require 'marc_to_argot/macros/duke/items'
      require 'marc_to_argot/macros/duke/physical_media'
      require 'marc_to_argot/macros/duke/resource_type'
      require 'marc_to_argot/macros/duke/shared_records'
      require 'marc_to_argot/macros/duke/urls'

      # Include this first. Then load Duke Macros.
      include MarcToArgot::Macros::Shared

      include MarcToArgot::Macros::Duke::Items
      include MarcToArgot::Macros::Duke::PhysicalMedia
      include MarcToArgot::Macros::Duke::ResourceType
      include MarcToArgot::Macros::Duke::SharedRecords
      include MarcToArgot::Macros::Duke::Urls

      # Sets the list of MARC org codes that are local.
      # Used by #subfield_5_present_with_local_code?
      def local_marc_org_codes
        %w[NcD NcD-B NcD-D NcD-L NcD-M NcD-W NcDurDH]
      end

      # If there's anything present in the physical_items
      # clipboard array then there ought to be at least
      # one physical item on the record.
      def physical_access?(rec, ctx = {})
        return true if ctx.clipboard.fetch(:physical_items, []).any?
      end

      # OCLC Number & Rollup ID

      def oclc_number
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("035|  |a").each_matching_line(rec) do |field|
            oclc_numbers = fetch_oclc_numbers(field).map! { |x| { value: x } }
            acc.concat(oclc_numbers)
          end
        end
      end

      def rollup_id
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("035|  |a").each_matching_line(rec) do |field|
            first_oclc_number = fetch_oclc_numbers(field).first
            acc << "OCLC#{first_oclc_number}" unless first_oclc_number.nil? || first_oclc_number.empty?
          end
        end
      end

      def fetch_oclc_numbers(field)
        oclc_numbers = field.subfields.select { |sf| sf.code == 'a' }.map(&:value).map(&:strip)
        oclc_numbers.select! { |x| /^(\(OCoLC\))?\d{8,}$/.match(x) }
        oclc_numbers.map! { |x| x.sub('(OCoLC)', '') }
        oclc_numbers.map! { |x| x.sub(/^0+/, '') }
        oclc_numbers
      end

      def add_bookplate_to_notes_local(ctx)
        if ctx.output_hash.key?('bookplate')
          bookplate = ctx.output_hash['bookplate'].map { |bp| { 'value' => bp } }
          local_notes = ctx.output_hash.fetch('note_local', [])
          ctx.output_hash['note_local'] = local_notes.concat(bookplate)
          ctx.output_hash.delete('bookplate')
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
