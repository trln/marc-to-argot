# frozen_string_literal: true
module MarcToArgot
  module Macros
    module Duke
      module TitleVariant
        ################################################
        # Title Variant
        ######
        # rubocop:disable Layout/LineLength
        # rubocop:disable Metrics/PerceivedComplexity
        def title_variant
          lambda do |rec, acc|
            Traject::MarcExtractor.cached('210a:222ab:246abfghnp:247abghnp').each_matching_line(rec) do |field, spec, extractor|
              next unless subfield_5_absent_or_present_with_local_code?(field)

              variant_titles = {}

              type = variant_title_type(field)
              variant_titles[:type] = type unless type.nil? || type.empty?

              label = variant_title_label(field)
              variant_titles[:label] = label unless label.nil? || label.empty?

              value = variant_title_value(field, spec, extractor)
              variant_titles[:value] = value unless value.nil? || value.empty?

              indexed_value = variant_title_indexed_value(field)
              variant_titles[:indexed_value] = indexed_value unless indexed_value.nil? || indexed_value.empty?

              issn = variant_title_issn(field)
              variant_titles[:issn] = issn unless issn.nil? || issn.empty?

              display = variant_title_display(field)
              variant_titles[:display] = display unless display.nil? || display.empty?

              next if (variant_titles[:value].nil? || variant_titles[:value].empty?) &&
                      (variant_titles[:indexed_value].nil? || variant_titles[:indexed_value].empty?)

              acc << variant_titles
            end
          end
        end
        # rubocop:enable Metrics/PerceivedComplexity
        # rubocop:enable Layout/LineLength

        def variant_title_type(field)
          case field.tag
          when '210'
            'abbrev'
          when '222'
            'key'
          when '247'
            'former'
          end
        end

        def variant_title_label(field)
          labels = []
          case field.tag
          when '246'
            unless index_only_246?(field)
              labels << 'Distinctive title' if field.indicator2 == '2'
              labels << 'Cover title' if field.indicator2 == '4'
              labels << 'Added title page title' if field.indicator2 == '5'
              labels << 'Caption title' if field.indicator2 == '6'
              labels << 'Running title' if field.indicator2 == '7'
              labels << 'Spine title' if field.indicator2 == '8'
              labels << collect_subfield_values_by_code(field, 'i').join(' ').chomp(':').strip
            end
          when '247'
            unless index_only_247?(field)
              labels << collect_subfield_values_by_code(field, 'f').join(' ').chomp(':').strip
            end
          end

          labels.compact.reject(&:empty?).join(': ')
        end

        def variant_title_value(field, spec, extractor)
          case field.tag
          when '210'
            extractor.collect_subfields(field, spec).first
          when '222'
            str = extractor.collect_subfields(field, spec).first
            Traject::Macros::Marc21Semantics.filing_version(field, str, spec)
          when '246'
            if index_only_246?(field)
              collect_and_join_subfield_values(field, %w[a b n p])
            else
              extractor.collect_subfields(field, spec).first
            end
          when '247'
            if index_only_247?(field)
              collect_and_join_subfield_values(field, %w[a b n p])
            else
              extractor.collect_subfields(field, spec).first.chomp('.').strip
            end
          end
        end

        def variant_title_indexed_value(field)
          case field.tag
          when '246'
            if !index_only_246?(field) && (%w[f g h] & field.subfields.map(&:code)).any?
              collect_and_join_subfield_values(field, %w[a b n p])
            end
          when '247'
            if !index_only_247?(field) && (%w[g h] & field.subfields.map(&:code)).any?
              collect_and_join_subfield_values(field, %w[a b n p])
            end
          end
        end

        def variant_title_issn(field)
          case field.tag
          when '247'
            collect_subfield_values_by_code(field, 'x').first
          end
        end

        def variant_title_display(field)
          case field.tag
          when /^(210|222)$/
            'false'
          when '246'
            'false' if index_only_246?(field)
          when '247'
            'false' if index_only_247?(field)
          end
        end

        def index_only_246?(field)
          # DUKE catalogers interpret "ind1='3'" differently
          # Also, DUKE is ignoring the value in "indicator 2"
          !%w[0 1 3].include?(field.indicator1) || %w[0].include?(field.indicator2)
          # !%w[0 1].include?(field.indicator1) || %w[0 1].include?(field.indicator2)
        end

        def index_only_247?(field)
          field.indicator2 != '0'
        end
      end
    end
  end
end
