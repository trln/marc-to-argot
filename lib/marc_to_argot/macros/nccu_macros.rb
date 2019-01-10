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

      def rollup_id
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("035a").each_matching_line(rec) do |field, spec, extractor|
            if field.value.include?('(OCoLC)')
              acc << field.value.gsub(/^\(OCoLC\)(\d+)$/, 'OCLC\1')
            elsif field.value.include?('(Sirsi)')
              Traject::MarcExtractor.cached("001").each_matching_line(rec) do |field, spec, extractor|
                if field.value.match(/^(ocm|ocn|on)?0\d+$/)
                  acc << field.value.gsub(/^(ocm|ocn|on)?0(\d+)$/, 'OCLC\2')
                end  
              end 
            end 
          end
        end    
      end

    end
  end
end
