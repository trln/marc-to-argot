module MarcToArgot
  module Macros
    module Shared
      module Edition
        ################################################################
        # Edition Macros
        ################################################################

        def edition
          lambda do |rec, acc|
            Traject::MarcExtractor.cached('250:254')
                                  .each_matching_line(rec) do |field, spec, extractor|

              edition = {}

              case field_tag_or_880_linkage_tag(field)
              when '250'
                label = collect_and_join_subfield_values(field, '3').chomp(':').strip
                value = collect_and_join_subfield_values(field, %w[a b])
              when '254'
                value = collect_and_join_subfield_values(field, %w[a])
              end

              next if value.nil? || value.empty?

              lang = Vernacular::ScriptClassifier.new(field, value).classify

              edition['label'] = label unless label.nil? || label.empty?
              edition['value'] = value
              edition['lang'] = lang unless lang.nil? || lang.empty?

              acc << edition unless edition.empty?
            end
          end
        end
      end
    end
  end
end
