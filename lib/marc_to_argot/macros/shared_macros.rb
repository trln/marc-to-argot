require 'marc_to_argot/macros/shared/helpers'
require 'marc_to_argot/macros/shared/call_numbers'
require 'marc_to_argot/macros/shared/edition'
require 'marc_to_argot/macros/shared/imprint'
require 'marc_to_argot/macros/shared/language'
require 'marc_to_argot/macros/shared/misc_id'
require 'marc_to_argot/macros/shared/names'
require 'marc_to_argot/macros/shared/creator_main' #placed here because it requires names
require 'marc_to_argot/macros/shared/notes'
require 'marc_to_argot/macros/shared/origin_place'
require 'marc_to_argot/macros/shared/physical_description'
require 'marc_to_argot/macros/shared/physical_media'
require 'marc_to_argot/macros/shared/publication_year'
require 'marc_to_argot/macros/shared/resource_type'
require 'marc_to_argot/macros/shared/series_statement'
require 'marc_to_argot/macros/shared/sersol_number'
require 'marc_to_argot/macros/shared/statement_of_responsibility'
require 'marc_to_argot/macros/shared/subject_genre'
require 'marc_to_argot/macros/shared/title'
require 'marc_to_argot/macros/shared/title_variant'
require 'marc_to_argot/macros/shared/upc'
require 'marc_to_argot/macros/shared/urls'
require 'marc_to_argot/macros/shared/vernacular'
require 'marc_to_argot/macros/shared/work_entry'

require 'set'

module MarcToArgot
  module Macros
    # Shared macros for TRLN institutions.  Default implementations are
    # defined here, and overriden in institution-specific modules in the
    # same namespace.
    module Shared
      include Helpers
      include CallNumbers
      include Edition
      include Imprint
      include Language
      include MiscId
      include Names
      include CreatorMain #placed here because it requires names
      include Notes
      include OriginPlace
      include PhysicalDescription
      include PublicationYear
      include PhysicalMedia
      include ResourceType
      include SeriesStatement
      include SersolNumber
      include StatementOfResponsibility
      include SubjectGenre
      include Title
      include TitleVariant
      include Upc
      include Urls
      include Vernacular
      include WorkEntry

      # values to look for in the 856 that indicate
      # a record has online access.
      ELOC_IND2 = Set.new(%w[0 1])

      def record_id
        oclcnum("035a:035z")
      end

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

      # Sets the list of MARC org codes that are local.
      # Used by #subfield_5_present_with_local_code?
      # Override in local macro to set a list of local
      # codes.
      def local_marc_org_codes
        []
      end

      # Returns true if the field does NOT have a subfield 5
      # OR if subfield 5 is present with a whitelisted local code
      # (see #local_marc_org_codes)
      # @param rec [MARC::Field] the field to be checked.
      def subfield_5_absent_or_present_with_local_code?(field)
        !subfield_5_present?(field) ||
          subfield_5_present_with_local_code?(field)
      end

      # Returns true if a subfield $5 is present in the field
      # @param rec [MARC::Field] the field to be checked.
      def subfield_5_present?(field)
        field.subfields.map(&:code).include?('5')
      end

      # Returns true if a subfield $5 is present in the field
      # AND the subfield $5 value(s) include a local code
      # (see #local_marc_org_codes)
      # @param rec [MARC::Field] the field to be checked.
      def subfield_5_present_with_local_code?(field)
        subfield_5_present?(field) &&
          (field.subfields.select { |sf| sf.code == '5' }.map { |sf| sf.value.strip } &
            local_marc_org_codes).any?
      end
    end
  end
end
