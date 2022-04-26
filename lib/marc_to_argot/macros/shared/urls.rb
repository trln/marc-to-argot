module MarcToArgot
  module Macros
    module Shared
      module Urls

        ################################################################
        # url macros
        ################################################################

        # accumulates an array of JSON blobs with URL data from a record.
        def url
          lambda do |rec, acc|
            Traject::MarcExtractor.cached("856uy3").each_matching_line(rec) do |field, spec, extractor|
              url = {}
              url[:href] = url_href_value(field)

              next if url[:href].nil? || url[:href].empty?

              url[:type] = url_type_value(field)
              url[:text] = url_text(field) unless url_text(field).empty?
              url[:note] = url_note(field) unless url_note(field).empty?

              acc << url.to_json
            end
          end
        end

        def url_href_value(field)
          collect_subfield_values_by_code(field, 'u').first
        end

        # returns a type value based on the 856 field's 2nd indicator value
        # @param field [MARC::DataField] the field to use to assign a type value
        def url_type_value(field)
          case field.indicator2
          when '0'
            type = 'fulltext'
          when '1'
            type = 'fulltext'
          when '2'
            type = 'related'
          else
            type = 'other'
          end

          type = 'findingaid' if url_for_finding_aid?(field)

          type = 'thumbnail' if url_for_thumbnail?(field)
            
          type
        end

        # tests whether the field contains a URL for a finding aid
        # @param field [MARC::DataField] the field to check for a finding aid URL
        def url_for_finding_aid?(field)
          substring_present_in_subfield?(field, '3', 'finding aid')
        end

        # tests whether the field contains a URL for a thumbnail
        # @param field [MARC::DataField] the field to check for a thumbnail URL
        def url_for_thumbnail?(field)
          substring_present_in_subfield?(field, '3', 'thumbnail')
        end

        # assembles a string from the 856 subfields y to use for the URL text
        # @param field [MARC::DataField] the field to use to assemble URL text
        def url_text(field)
          subfield_values_y = collect_subfield_values_by_code(field, 'y')
          [subfield_values_y.join(' ')].reject(&:empty?).join(' ')
        end

        # assembles a string from the 856 subfields 3 to use for the URL note
        # @param field [MARC::DataField] the field to use to assemble URL note
        def url_note(field)
          subfield_values_3 = collect_subfield_values_by_code(field, '3')
          [subfield_values_3.join(' ')].reject(&:empty?).join(' ')
        end
      end
    end
  end
end
