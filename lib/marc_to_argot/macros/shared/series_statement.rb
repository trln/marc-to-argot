module MarcToArgot
  module Macros
    module Shared
      module SeriesStatement
        ################################################################
        # series statement macros
        ################################################################

        def series_statement
          lambda do |rec, acc|
            Traject::MarcExtractor.cached('440:490')
                                  .each_matching_line(rec) do |field, spec, extractor|

              next unless subfield_5_absent_or_present_with_local_code?(field)

              series_statement = assemble_series_statement_hash(field, rec)

              acc << series_statement unless series_statement.empty?
            end
          end
        end

        def assemble_series_statement_hash(field, rec)
          series_statement = {}

          series_statement['label'] = series_statement_label(field)
          series_statement['value'] = series_statement_value(field)
          series_statement['issn'] = series_statement_issn(field)
          series_statement['other_ids'] = series_statement_other_ids(field)

          lang = Vernacular::ScriptClassifier.new(field, series_statement['value']).classify
          series_statement['lang'] = lang unless lang.nil? || lang.empty?

          series_statement.delete_if { |k, v| v.nil? || v.empty? }
        end

        def series_statement_label(field)
          case field_tag_or_880_linkage_tag(field)
          when '490'
            collect_and_join_subfield_values(field, '3').chomp(':').strip
          end
        end

        def series_statement_value(field)
          case field_tag_or_880_linkage_tag(field)
          when '440'
            collect_and_join_subfield_values(field, %w[a n p v x])
          when '490'
            collect_and_join_subfield_values(field, %w[a l v x])
          end
        end

        def series_statement_issn(field)
          case field_tag_or_880_linkage_tag(field)
          when '440', '490'
            collect_subfield_values_by_code(field, 'x').map do |v|
              extract_identifier(v).chomp(';').strip
            end
          end
        end

        def series_statement_other_ids(field)
          case field_tag_or_880_linkage_tag(field)
          when '440'
            collect_subfield_values_by_code(field, 'w').map do |v|
              split_identifier_and_qualifier(v)[-1]
            end
          end
        end
      end
    end
  end
end
