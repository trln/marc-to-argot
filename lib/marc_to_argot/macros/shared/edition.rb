module MarcToArgot
  module Macros
    module Shared
      module Edition
        ################################################################
        # Edition Macros
        ################################################################

        def edition
          lambda do |rec, acc|
            Traject::MarcExtractor.cached('250:254', :alternate_script => false)
                                  .each_matching_line(rec) do |field, spec, extractor|

              edition = {}

              case field.tag
                when '250'
                  label = collect_and_join_subfield_values(field, '3').chomp(':').strip
                  edition['label'] = label unless label.empty?
                  edition['value'] = collect_and_join_subfield_values(field, %w[a b])
                when '254'
                  edition['value'] = collect_and_join_subfield_values(field, %w[a])
                end  

              acc << edition unless edition.empty?

            end
          end
        end
      end
    end
  end
end
