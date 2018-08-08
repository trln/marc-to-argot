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
          
          def get_general_formats
            UncResourceTypeClassifier.new(record).formats
          end
          
          def unc_formats
            formats = get_general_formats
            if unc_archival?
              formats << 'Archival and manuscript material'
            end
            if unc_manuscript?
              formats = []
              formats << 'Archival and manuscript material'
            end
            if unc_manuscript?
              formats = []
              formats << 'Archival and manuscript material'
            end
            if unc_thesis_dissertation?
              formats.delete('Archival and manuscript material')
              formats.delete('Book')
              formats << 'Thesis/Dissertation'
              formats << 'Book' unless has_502?
            end
            formats.uniq
          end

          def manuscript_lang_rec_type?
            record.leader.byteslice(6) == 't'
          end

          def lang_rec_type?
            record.leader.byteslice(6) == 'a'
          end

          def unc_archival?
            archival_control? && archival_bib_level?
          end

          def archival_control?
            record.leader.byteslice(8) == 'a'
          end

          def archival_bib_level?
            %w[c d].include?(record.leader.byteslice(7))
          end

          def book_008?
            return true if ( manuscript_lang_rec_type? ||
                             ( lang_rec_type? && %w[a c d m].include?(record.leader.byteslice(7)))
          end
          
          def unc_manuscript?
            return true if manuscript_lang_rec_type? unless has_502?
          end
          
          # Thesis/Dissertation
          # LDR/06 = a AND 008/24-27(any) = m
          # OR
          # LDR/06 = t AND 008/24-27(any) = m
          # OR
          # 006/00 = a AND 006/07-10(any) = m
          def unc_thesis_dissertation?
            rec_type_match = manuscript_lang_rec_type? || lang_rec_type?
            nature_contents_match = record.fields('008').find do |field|
              (field.value.byteslice(24..27) || '').split('').include?('m')
            end

            marc_006_match_results = record.fields('006').collect do |field|
              %w[a].include?(field.value.byteslice(0)) &&
                (field.value.byteslice(7..10) || '').split('').include?('m')
            end

            return true if (rec_type_match && nature_contents_match) ||
                           marc_006_match_results.include?(true) ||
                           rec_type_match && has_502?
          end

          def has_502?
            return true unless record.fields('502').empty?
          end

        end
      end
    end
  end
end
