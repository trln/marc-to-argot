module MarcToArgot
  module Macros
    module UNC
      module ResourceType
        include MarcToArgot::Macros::Shared::ResourceType

        def resource_type
          lambda do |rec, acc|
            acc.concat UncResourceTypeClassifier.new(rec).unc_formats
          end
        end

        class UncResourceTypeClassifier < ResourceTypeClassifier
          attr_reader :record
          
          def initialize(rec)
            super
          end

          def get_general_formats
            UncResourceTypeClassifier.new(record).formats
          end
          
          def unc_formats
            formats = get_general_formats
            if unc_thesis_dissertation?
              formats.delete('Archival and manuscript material')
              formats << 'Thesis/Dissertation'
            end
            formats
          end
          
          # Thesis/Dissertation
          # LDR/06 = a AND 008/24-27(any) = m
          # OR
          # LDR/06 = t AND 008/24-27(any) = m
          # OR
          # 006/00 = a AND 006/07-10(any) = m
          def unc_thesis_dissertation?
            rec_type_match = %[a t].include?(record.leader.byteslice(6))
            nature_contents_match = record.fields('008').find do |field|
              (field.value.byteslice(24..27) || '').split('').include?('m')
            end

            marc_006_match_results = record.fields('006').collect do |field|
              %w[a].include?(field.value.byteslice(0)) &&
                (field.value.byteslice(7..10) || '').split('').include?('m')
            end

            return true if (rec_type_match && nature_contents_match) ||
                           marc_006_match_results.include?(true)
          end  

        end
      end
    end
  end
end
