module MarcToArgot
  module Macros
    module Shared
      module IncludedWork
        ################################################
        # Included Work
        ######
        def included_work
          lambda do |rec, acc|
            Traject::MarcExtractor.cached('700|*2|:710|*2|:711|*2|:730|*2|:740|*2|:774')
                                  .each_matching_line(rec) do |field, spec, extractor|
              next unless subfield_5_absent_or_present_with_local_code?(field)

              included_work = {}

              type = included_work_type(field)
              label = included_work_label(field)
              author = included_work_author(field, spec, extractor)
              title = included_work_title(field, spec, extractor)
              title_nonfiling = included_work_title_nonfiling(field)
              title_variation = included_work_title_variation(field)
              details = included_work_details(field)
              issn = included_work_issn(field)
              isbn = included_work_isbn(field)
              other_ids = included_work_other_ids(field)
              display = included_work_display(field)

              included_work['type'] = type unless type.nil? || type.empty?
              included_work['label'] = label unless label.nil? || label.empty?
              included_work['author'] = author unless author.nil? || author.empty?
              included_work['title'] = title unless title.nil? || title.empty?
              included_work['title_nonfiling'] = title_nonfiling unless title_nonfiling.nil? || title_nonfiling.empty?
              included_work['title_variation'] = title_variation unless title_variation.nil? || title_variation.empty?
              included_work['details'] = details unless details.nil? || details.empty?
              included_work['issn'] = issn unless issn.nil? || issn.empty?
              included_work['isbn'] = isbn unless isbn.nil? || isbn.empty?
              included_work['other_ids'] = other_ids unless other_ids.nil? || other_ids.empty?
              included_work['display'] = display unless display.nil? || display.empty?

              acc << included_work unless included_work.empty?
            end
          end
        end

        ################################################
        # Type: Included Work
        ######
        def included_work_type(field)
          case field.tag
          when /(700|710|711)/
            return unless passes_constraint_has_tk?(field)
            'included'
          when /(730|740)/
            'included'
          when '774'
            return unless passes_constraint_has_ts?(field)
            'included'
          end
        end

        ################################################
        # Label: Included Work
        ######
        def included_work_label(field)
          label = []
          case field.tag
          when /(700|710|711)/
            return unless passes_constraint_has_tk?(field)
            label << collect_subfield_3_label_values(field)
            label << process_subfield_i(field)
          when '730'
            label << collect_subfield_3_label_values(field)
            label << process_subfield_i(field)
          when '774'
            return unless passes_constraint_has_ts?(field) && field.indicator1 == '0'
            label << process_subfield_i(field)
          end
          label.flatten.compact.select { |l| !l.empty? }.join(": ")
        end

        def collect_subfield_3_label_values(field)
          field.subfields.select { |sf| sf.code == '3' }.map(&:value).first.to_s.chomp(":")
        end

        def process_subfield_i(field)
          field.subfields.select { |sf| sf.code == 'i' }
               .map { |i| i.value.gsub(/\s\((work|expression|manifestation|item)\)/, '')
                                 .chomp(":")
                                 .capitalize
                                 .gsub('Container of', 'Contains')
                                 .gsub('Contained in', "In") }
        end

        ################################################
        # Author: Included Work
        ######
        def included_work_author(field, spec, extractor)
          case field.tag
          when '700'
            return unless passes_constraint_has_tk?(field)
            collect_subfield_if_before(field, %w[a b c d j q u], 'g', %w[t k])
          when '710'
            return unless passes_constraint_has_tk?(field)
            collect_subfield_if_before(field, %w[a b c u], %w[d g n], %w[t k])
          when '711'
            return unless passes_constraint_has_tk?(field)
            collect_subfield_if_before(field, %w[a c e u], %w[d g n], %w[t k])
          when '774'
            return unless passes_constraint_has_ts?(field)
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
        # Title: Included Work
        ######
        def included_work_title(field, spec, extractor)
          case field.tag
          when '700'
            return unless passes_constraint_has_tk?(field)
            collect_subfield_if_after(field, %w[f h k l m n o p r s t], 'g', %w[t k])
          when '710'
            return unless passes_constraint_has_tk?(field)
            collect_subfield_if_after(field, %w[f h k l m o p r s t], %w[d g n], %w[t k])
          when '711'
            return unless passes_constraint_has_tk?(field)
            collect_subfield_if_after(field, %w[f h k l m p s t], %w[d g n], %w[t k])
          when '730'
            collect_filing_title_from_subfields(field, %w[a d f g h k l m n o p r s])
          when '740'
            collect_filing_title_from_subfields(field, %w[a h n p])
          when '774'
            sf_codes = field.subfields.map(&:code)
            if sf_codes.include?('t') && !sf_codes.include?('s')
              return collect_subfield_values_by_code(field, 't')
            end
            if sf_codes.include?('t') && sf_codes.include?('s')
              return collect_subfield_values_by_code(field, 's')
            end
          end
        end

        def collect_subfield_if_after(field, spec_passthrough, spec_restricted, spec_after)
          first_index_of_spec_after = field.subfields.index { |sf|  spec_after.include?(sf.code) }
          selected_fields = field.subfields.select.with_index do |sf, index|
            spec_passthrough.include?(sf.code) ||
              ([*spec_restricted].include?(sf.code) && index > first_index_of_spec_after)
          end
          selected_fields.map { |sf| sf.value.strip } #.join('||')
        end

        def collect_filing_title_from_subfields(field, spec)
          title = collect_subfield_values_by_code(field, spec)
          non_filing_chars = field.indicator1.to_s.to_i
          title[0] = title[0][non_filing_chars..-1]
          title[0] = title[0].split('')
          title[0].first.upcase!
          title[0] = title[0].join
          title
        end

        ################################################
        # Title Non-filing: Included Work
        ######
        def included_work_title_nonfiling(field)
          case field.tag
          when '730'
            return if field.indicator1.to_s.to_i < 1
            collect_and_join_subfield_values(field, %w[a d f g h k l m n o p r s])
          when '740'
            return if field.indicator1.to_s.to_i < 1
            collect_and_join_subfield_values(field, %w[a h n p])
          end
        end

        ################################################
        # Title Variation: Included Work
        ######
        def included_work_title_variation(field)
          case field.tag
          when '730'
            collect_and_join_subfield_values(field, 't')
          when '774'
            sf_codes = field.subfields.map(&:code)
            return unless sf_codes.include?('t') && sf_codes.include?('s')
            collect_and_join_subfield_values(field, 't')
          end
        end

        ################################################
        # Details: Included Work
        ######
        def included_work_details(field)
          case field.tag
          when '774'
            return unless passes_constraint_has_ts?(field) && field.indicator1 == '0'
            field.subfields.select { |sf| %w[b c d g h k m n o r u y].include?(sf.code) }
                           .map { |sf| translate_774_subfield_codes(sf) }
                           .join(' ')
          end
        end

        def translate_774_subfield_codes(sf)
          if %w[b c d g h k m n o].include?(sf.code)
            sf.value
          elsif sf.code == 'r'
            "Report number: #{sf.value}"
          elsif sf.code == 'u'
            "Technical report number: #{sf.value}"
          elsif sf.code == 'y'
            "CODEN:  #{sf.value}"
          end
        end

        ################################################
        # ISSN: Included Work
        ######
        def included_work_issn(field)
          case field.tag
          when /(700|710|711)/
            return unless passes_constraint_has_tk?(field)
            collect_issn_from_sf_x(field)
          when '730'
            collect_issn_from_sf_x(field)
          when '774'
            return unless passes_constraint_has_ts?(field)
            collect_issn_from_sf_x(field)
          end
        end

        def collect_issn_from_sf_x(field)
          field.subfields.select { |sf| sf.code == 'x' }.map(&:value).first
        end

        ################################################
        # ISBN: Included Work
        ######
        def included_work_isbn(field)
          case field.tag
          when '774'
            return unless passes_constraint_has_ts?(field)
            collect_subfield_values_by_code(field, 'z')
          end
        end

        ################################################
        # Other IDs: Included Work
        ######
        def included_work_other_ids(field)
          case field.tag
          when '774'
            return unless passes_constraint_has_ts?(field)
            field.subfields.select { |sf| %w[o r u w y].include?(sf.code) }
                           .map { |sf| remove_parenthetical_id_prefix_from_774(sf) }
          end
        end

        def remove_parenthetical_id_prefix_from_774(sf)
          if %w[o r u y].include?(sf.code)
            sf.value
          elsif sf.code == 'w'
            sf.value.gsub(/^\s*\(.*\)\s*/, '')
          end
        end

        ################################################
        # Display: Included Work
        ######
        def included_work_display(field)
          case field.tag
          when '774'
            return unless passes_constraint_has_ts?(field) && field.indicator1 == '1'
            'false'
          end
        end

        ################################################
        # Constraints: Included Work
        ######

        def passes_constraint_has_tk?(field)
          (%w[t k] & field.subfields.map(&:code)).any?
        end

        def passes_constraint_has_ts?(field)
          (%w[t s] & field.subfields.map(&:code)).any?
        end
      end
    end
  end
end
