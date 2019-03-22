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

            # General logic sets these on way more things than they should
            formats.delete('Dataset -- Statistical')
            formats.delete('Dataset -- Geospatial')
            
            if unc_archival?
              formats << 'Archival and manuscript material'
            end
            if unc_dataset_geospatial?
              formats << 'Dataset -- Geospatial'
            end
            if unc_dataset_statistical?
              formats << 'Dataset -- Statistical'
            end
            if unc_manuscript?
              formats = []
              formats << 'Archival and manuscript material'
            end
            if unc_text_corpus?
              formats.delete('Book')
              formats << 'Text corpus'
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

          def computer_rec_type?
            record.leader.byteslice(6) == 'm'
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
                           )
          end

          def get_iii_mattype
            the999s = record.fields('999')
            bib999arr = the999s.select { |f| f.indicator1 == '0' }
            bib999 = bib999arr.first
            bib999['m'] if bib999
          end

          def unc_dataset_statistical?
            return true if get_iii_mattype == '8'
          end

          def unc_dataset_geospatial?
            return true if get_iii_mattype == '7'
          end
                    
          def unc_manuscript?
            return true if manuscript_lang_rec_type? unless has_502?
          end

          def the_336_contains(string_regexp)
            regexp = Regexp.new(string_regexp)
            match336s = record.fields('336').map{ |f| f.to_s.downcase }.select{ |f| regexp.match(f) }
            return true unless match336s.empty?
          end

          def byte_of_008_equals(position, value)
            return true if record['008'].value.byteslice(position) == value
          end

          def has_lang_006?
            match006s = record.fields('006').select{ |f| f.value.byteslice(0) == 'a' }
            return true unless match006s.empty?
          end

          # Software/multimedia
          def software_mm_comp_file_types
            %w[b f g i]
           end
          
          # Text corpus
          # LDR/06 = m AND 008/26 = d AND 006/00 = a AND 336 contains dataset or cod
          def unc_text_corpus?
            return true if (computer_rec_type? &&
                            byte_of_008_equals(26, 'd') &&
                            has_lang_006? &&
                            the_336_contains('dataset|cod')
                           )
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
