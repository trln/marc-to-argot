module MarcToArgot
  module Macros
    module Shared
      module WorkEntry
        ################################################
        # Work Entry
        ######
        def included_work
          lambda do |rec, acc|
            Traject::MarcExtractor.cached('700|*2|:710|*2|:711|*2|:730|*2|:740|*2|:774')
                                  .each_matching_line(rec) do |field, spec, extractor|
              next unless subfield_5_absent_or_present_with_local_code?(field)
              included_work = assemble_work_entry_hash(field)

              acc << included_work unless included_work.empty?
            end
          end
        end

        def related_work
          lambda do |rec, acc|
            Traject::MarcExtractor.cached('700|* |:710|* |:711|* |:730|* |:740|* |:'\
                                          '765:767:770:772:773:775:777:780:785:786:787')
                                  .each_matching_line(rec) do |field, spec, extractor|
              next unless subfield_5_absent_or_present_with_local_code?(field)
              related_work = assemble_work_entry_hash(field)

              acc << related_work unless related_work.empty?
            end
          end
        end

        def assemble_work_entry_hash(field)
          work_entry = {}

          work_entry['type'] = work_entry_type(field)
          work_entry['label'] = work_entry_label(field)
          work_entry['author'] = work_entry_author(field)
          work_entry['title'] = work_entry_title(field)
          work_entry['title_nonfiling'] = work_entry_title_nonfiling(field)
          work_entry['title_variation'] = work_entry_title_variation(field)
          work_entry['details'] = work_entry_details(field)
          work_entry['issn'] = work_entry_issn(field)
          work_entry['isbn'] = work_entry_isbn(field)
          work_entry['other_ids'] = work_entry_other_ids(field)
          work_entry['display'] = work_entry_display(field)

          work_entry.delete_if { |k, v| v.nil? || v.empty? }
        end

        ################################################
        # Type: Work Entry
        ######
        def work_entry_type(field)
          return unless passes_work_entry_constraint?(field)

          case field.tag
          when /(700|710|711|730|740)/
            work_entry_type_70x_71x_73x_74x(field)
          when /(765|767|770|772|773|774|775|777|780|785|786|787)/
            work_entry_type_76x_77x_78x(field)
          end
        end

        def work_entry_type_70x_71x_73x_74x(field)
          case field.indicator2
          when '2'
            'included'
          when ' '
            'related'
          end
        end

        def work_entry_type_76x_77x_78x(field)
          case field.tag
          when '765'
            'translation_of'
          when '767'
            'translated_as'
          when '770'
            'has_supplement'
          when '772'
            'supplement_to'
          when '773'
            'host_item'
          when '774'
            'included'
          when '775'
            'alt_edition'
          when '777'
            'issued_with'
          when '780'
            'earlier'
          when '785'
            'later'
          when '786'
            'data_source'
          when '787'
            'related'
          end
        end

        ################################################
        # Label: Work Entry
        ######
        def work_entry_label(field)
          return unless passes_work_entry_constraint?(field) &&
                        passes_work_entry_label_constraint?(field)

          label = []
          case field.tag
          when /(700|710|711|730|773)/
            label.concat work_entry_label_70x_71x_73x_773(field)
          when /(765|767|770|774|777|786|787)/
            label << process_subfield_i(field)
          when /(772|775|780|785)/
            label.concat work_entry_labels_772_775_780_785(field)
          end

          label.flatten.compact.select { |l| !l.empty? }.map { |v| capitalize_first_letter(v) }.join(": ")
        end

        def work_entry_labels_772_775_780_785(field)
          labels = []
          sf_codes = field.subfields.map(&:code)
          if sf_codes.include?('i')
            labels << process_subfield_i(field)
          else
            labels << work_entry_labels_772_775_780_785_no_sf_e(field)
          end
          labels
        end

        def work_entry_labels_772_775_780_785_no_sf_e(field)
          sf_codes = field.subfields.map(&:code)
          case field.tag
          when '772'
            if field.indicator2 == '0' && !sf_codes.include?('4')
              'Parent item'
            end
          when '775'
            if !sf_codes.include?('4')
              process_subfield_e(field)
            end
          when '780'
            translate_780_i2(field)
          when '785'
            translate_785_i2(field)
          end
        end

        def passes_work_entry_label_constraint?(field)
          case field.tag
          when /(765|767|770|772|773|774|775|777|780|785|786|787)/
            field.indicator1 == '0'
          else
            true
          end
        end

        def work_entry_label_70x_71x_73x_773(field)
          label = []
          label << collect_subfield_3_label_values(field)
          label << process_subfield_i(field)
          label
        end

        def collect_subfield_3_label_values(field)
          field.subfields.select { |sf| sf.code == '3' }.map(&:value).first.to_s.chomp(":")
        end

        def process_subfield_i(field)
          field.subfields.select { |sf| sf.code == 'i' }
               .map { |i| i.value.gsub(/\s\((work|expression|manifestation|item)\)/, '')
                                 .chomp(":")
                                 .gsub('Container of', 'Contains')
                                 .gsub('Contained in', "In") }
        end

        def process_subfield_e(field)
          translation_map = Traject::TranslationMap.new("marc_languages")
          languages = field.subfields.select { |sf| sf.code == 'e' }.map do |sf|
            translation_map[sf.value]
          end
          return "#{languages.first} language edition" if languages.any?
        end

        def translate_780_i2(field)
          case field.indicator2
          when '0'
            'Continues'
          when '1'
            'Continues in part'
          when '2'
            'Supersedes'
          when '3'
            'Supersedes in part'
          when '4'
            'Formed by the union of'
          when '5'
            'Absorbed'
          when '6'
            'Absorbed in part'
          when '7'
            'Separated from'
          end
        end

        def translate_785_i2(field)
          case field.indicator2
          when '0'
            'Continued by'
          when '1'
            'Continued in part by'
          when '2'
            'Superseded by'
          when '3'
            'Superseded in part by'
          when '4'
            'Absorbed by'
          when '5'
            'Absorbed in part by'
          when '6'
            'Split into'
          when '7'
            'Merged with or into'
          when '8'
            'Changed back to'
          end
        end

        ################################################
        # Author: Work Entry
        ######
        def work_entry_author(field)
          return unless passes_work_entry_constraint?(field)
          case field.tag
          when '700'
            collect_subfield_if_before(field, %w[a b c d j q u], 'g', %w[t k])
          when '710'
            collect_subfield_if_before(field, %w[a b c u], %w[d g n], %w[t k])
          when '711'
            collect_subfield_if_before(field, %w[a c e u], %w[d g n], %w[t k])
          when /(765|767|770|772|773|774|775|777|780|785|786|787)/
            gsub_final_comma_with_period(collect_and_join_subfield_values(field, 'a'))
          end
        end

        def collect_subfield_if_before(field, spec_passthrough, spec_restricted, spec_before)
          first_index_of_spec_before = field.subfields.index { |sf|  spec_before.include?(sf.code) }
          selected_fields = field.subfields.select.with_index do |sf, index|
            spec_passthrough.include?(sf.code) ||
              ([*spec_restricted].include?(sf.code) && index < first_index_of_spec_before)
          end
          gsub_final_comma_with_period(selected_fields.map(&:value).join(' '))
        end

        def gsub_final_comma_with_period(field_value)
          field_value.gsub(/,\s*$/, '.')
        end

        ################################################
        # Title: Work Entry
        ######

        # TODO: Refactor This
        def work_entry_title(field)
          return unless passes_work_entry_title_constraint?(field)

          case field.tag
          when '700'
            collect_subfield_if_after(field, %w[f h k l m n o p r s t], 'g', %w[t k])
          when '710'
            collect_subfield_if_after(field, %w[f h k l m o p r s t], %w[d g n], %w[t k])
          when '711'
            collect_subfield_if_after(field, %w[f h k l m p s t], %w[d g n], %w[t k])
          when '730'
            collect_filing_title_from_subfields(field, %w[a d f g h k l m n o p r s])
          when '740'
            collect_filing_title_from_subfields(field, %w[a h n p])
          when /(765|767|770|772|773|774|775|777|780|785|786|787)/
            work_entry_title_76x_77x_78x(field)
          end
        end

        def work_entry_title_76x_77x_78x(field)
          sf_codes = field.subfields.map(&:code)
          return unless sf_codes.include?('t')
          if sf_codes.include?('s')
            work_entry_segmented_titles_76x_77x_78x(field, 's')
          else
            work_entry_segmented_titles_76x_77x_78x(field, 't')
          end
        end

        def work_entry_segmented_titles_76x_77x_78x(field, subfield)
          values = collect_subfield_values_by_code(field, subfield)
          if field.indicator1 == '1'
            values
          else
            WorkEntryTitleSegmenter.segment_title(values.join(' '))
          end
        end

        def passes_work_entry_title_constraint?(field)
          case field.tag
          when /(700|710|711)/
            passes_constraint_has_tk?(field)
          else
            true
          end
        end

        def collect_subfield_if_after(field, spec_passthrough, spec_restricted, spec_after)
          first_index_of_spec_after = field.subfields.index { |sf|  spec_after.include?(sf.code) }
          selected_fields = field.subfields.select.with_index do |sf, index|
            spec_passthrough.include?(sf.code) ||
              ([*spec_restricted].include?(sf.code) && index > first_index_of_spec_after)
          end
          selected_fields.map { |sf| sf.value.strip }
        end

        def collect_filing_title_from_subfields(field, spec)
          title = collect_subfield_values_by_code(field, spec)
          non_filing_chars = field.indicator1.to_s.to_i
          title[0] = title[0][non_filing_chars..-1]
          title[0] = capitalize_first_letter(title[0])
          title
        end

        ################################################
        # Title Non-filing: Work Entry
        ######
        def work_entry_title_nonfiling(field)
          return unless passes_work_entry_title_nonfiling_constraint?(field)
          case field.tag
          when '730'
            collect_and_join_subfield_values(field, %w[a d f g h k l m n o p r s])
          when '740'
            collect_and_join_subfield_values(field, %w[a h n p])
          when /(773|780)/
            collect_and_join_subfield_values(field, 'p')
          end
        end

        def passes_work_entry_title_nonfiling_constraint?(field)
          case field.tag
          when /(730|740)/
            field.indicator1.to_s.to_i > 0
          when /(773|780)/
            passes_constraint_has_ts?(field)
          else
            true
          end
        end

        ################################################
        # Title Variation: Work Entry
        ######
        def work_entry_title_variation(field)
          return unless passes_work_entry_title_variation_constraint?(field)
          case field.tag
          when /(730|765|767|770|772|773|774|775|777|780|785|786|787)/
            collect_and_join_subfield_values(field, 't')
          end
        end

        def passes_work_entry_title_variation_constraint?(field)
          sf_codes = field.subfields.map(&:code)
          case field.tag
          when '730'
            sf_codes.include?('t') && sf_codes.include?('a')
          when /(765|767|770|772|773|774|775|777|780|785|786|787)/
            sf_codes.include?('t') && sf_codes.include?('s')
          else
            true
          end
        end

        ################################################
        # Details: Work Entry
        ######
        def work_entry_details(field)
          case field.tag
          when /(765|767|770|772|773|774|775|777|780|785|786|787)/
            return unless passes_constraint_has_ts?(field) && field.indicator1 == '0'
            field.subfields.select { |sf| work_entry_details_subfields(field).include?(sf.code) }
                           .map { |sf| translate_details_subfield_codes(sf) }
                           .join(' ')
          end
        end

        def work_entry_details_subfields(field)
          case field.tag
          when /(765|767|770|772|774|775|777|780|785|787)/
            %w[b c d g h k m n o r u y]
          when '773'
            %w[b d g h k m n o r u y]
          when '786'
            %w[b c d g h k m n o r u v y]
          end
        end

        def translate_details_subfield_codes(sf)
          if %w[b c d g h m n o].include?(sf.code)
            sf.value
          elsif sf.code == 'k'
            "(#{sf.value})"
          elsif sf.code == 'r'
            "Report number: #{sf.value}"
          elsif sf.code == 'u'
            "Technical report number: #{sf.value}"
          elsif sf.code == 'v'
            "Contributed: #{sf.value}"
          elsif sf.code == 'y'
            "CODEN: #{sf.value}"
          end
        end

        ################################################
        # ISSN: Work Entry
        ######
        def work_entry_issn(field)
          return unless passes_work_entry_constraint?(field)
          collect_issn_from_sf_x(field)
        end

        def collect_issn_from_sf_x(field)
          field.subfields.select { |sf| sf.code == 'x' }.map(&:value).first
        end

        ################################################
        # ISBN: Work Entry
        ######
        def work_entry_isbn(field)
          case field.tag
          when /(765|767|770|772|773|774|775|777|780|785|786|787)/
            return unless passes_constraint_has_ts?(field)
            collect_subfield_values_by_code(field, 'z')
          end
        end

        ################################################
        # Other IDs: Work Entry
        ######
        def work_entry_other_ids(field)
          case field.tag
          when /(765|767|770|772|773|774|775|777|780|785|786|787)/
            return unless passes_constraint_has_ts?(field)
            field.subfields.select { |sf| %w[o r u w y].include?(sf.code) }
                           .map { |sf| remove_parenthetical_id_prefix_from_sf_w(sf) }
          end
        end

        def remove_parenthetical_id_prefix_from_sf_w(sf)
          if %w[o r u y].include?(sf.code)
            sf.value
          elsif sf.code == 'w'
            sf.value.gsub(/^\s*\(.*\)\s*/, '')
          end
        end

        ################################################
        # Display: Work Entry
        ######
        def work_entry_display(field)
          case field.tag
          when /(765|767|770|772|773|774|775|777|780|785|786|787)/
            return unless passes_constraint_has_ts?(field) && field.indicator1 == '1'
            'false'
          end
        end

        ################################################
        # Constraints: Work Entry
        ######

        def passes_work_entry_constraint?(field)
          case field.tag
          when /(700|710|711)/
            passes_constraint_has_tk?(field)
          when /(765|767|770|772|773|774|775|777|780|785|786|787)/
            passes_constraint_has_ts?(field)
          else
            true
          end
        end

        def passes_constraint_has_tk?(field)
          (%w[t k] & field.subfields.map(&:code)).any?
        end

        def passes_constraint_has_ts?(field)
          (%w[t s] & field.subfields.map(&:code)).any?
        end


        ################################################
        # WorkEntryTitleSegmenter: Segments title strings on periods
        #  with some noted exceptions. Wrapping in a class to isolate
        #  these details.
        ######
        class WorkEntryTitleSegmenter
          def self.segment_title(str)
            segments = split_on_open_parens(str)
            segments = split_parentheticals_on_colon(segments)
            segments = split_parentheticals_on_close(segments)
            segments = split_on_periods_with_exceptions(segments)
            segments.select { |v| !v.empty? }
          end

          def self.split_on_open_parens(str)
            str.split(/(?=[(])/)
          end

          def self.split_parentheticals_on_colon(array)
            array.map do |segment|
              if segment =~ /[\(\)]/
                segment.split(/(?<=[:])/)
              else
                segment
              end
            end.flatten
          end

          def self.split_parentheticals_on_close(array)
            array.map do |segment|
              if segment =~ /[\(\)]/ && segment !~ /\.$/
                segment.split(/(?<=[\)])/)
              else
                segment
              end
            end.flatten
          end

          def self.split_on_periods_with_exceptions(array)
            segments = array.map do |segment|
              # Map certain periods in segments without parentheticals
              # to a temporary character to exclude them from the split
              # on period rule.

              # Process segments without parentheticals.
              if segment !~ /[\(\)]/
                # Exclude elipses: '...'
                segment.gsub!(/\.{3}/, '|||||||||')
                # Excluded two letter abbreviations: 'C.J.' 'i.e.', etc.
                segment.gsub!(/([A-Za-z])\.([A-Za-z])\./, '\1|||\2|||')
                # Exclude single letter abbreviations: ' J. '
                segment.gsub!(/\s([A-Za-z])\.\s/, ' \1||| ')
                # Split segments on remaining periods
                segment.split(/(?<=[\.])/)
              else
                segment
              end
            end.flatten.compact

            # Convert placeholder preserved periods back to '.'
            segments.map { |v| v.gsub('|||', '.').strip }
          end
        end
      end
    end
  end
end
