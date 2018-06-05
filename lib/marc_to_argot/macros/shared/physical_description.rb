module MarcToArgot
  module Macros
    module Shared
      module PhysicalDescription
        ################################################################
        # Physical Description Macros
        ################################################################

        def physical_description
          description('300')
        end

        # NOTE: Alternate/vernacular scripts are excluded from processing
        #       for now. Handling details TBD.
        def description(conf)
          lambda do |rec, acc|
            Traject::MarcExtractor.cached(conf, :alternate_script => false)
                                  .each_matching_line(rec) do |field, spec, extractor|

              # next unless passes_work_entry_constraint?(field, rec)
              # next unless subfield_5_absent_or_present_with_local_code?(field)

              description = assemble_description_hash(field, rec)

              acc << description unless description.empty?
            end
          end
        end

        def assemble_description_hash(field, rec)
          description = {}

          description['label'] = description_label(field)
          description['value'] = description_value(field)

          description.delete_if { |k, v| v.nil? || v.empty? }
        end

        def description_label(field)
          case field.tag
          when '300'
            collect_and_join_subfield_values(field, '3')
          end
        end

        def description_value(field)
          case field.tag
          when '300'
            collect_and_join_subfield_values(field, %w[a b c e f g])
          end
        end
      end
    end
  end
end
