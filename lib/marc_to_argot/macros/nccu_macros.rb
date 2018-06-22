module MarcToArgot
  module Macros
    # Macros and useful functions for NCCU records
    module NCCU
      autoload :Items, 'marc_to_argot/macros/nccu/items'

      include MarcToArgot::Macros::NCCU::Items
      include MarcToArgot::Macros::Shared

      # Sets the list of MARC org codes that are local.
      # Used by #subfield_5_present_with_local_code?
      def local_marc_org_codes
        %w[NcDurC NcDurCL]
      end

      def url_for_finding_aid?(fld)
        substring_present_in_subfield?(fld, 'u', 'https://finding-aids.lib.unc.edu/')
      end

      def online_access?(_rec, libraries = [])
        libraries.include?('ONLINE')
      end

      def physical_access?(_rec, libraries = [])
        !libraries.find { |x| x != 'ONLINE' }.nil?
      end

    end
  end
end
