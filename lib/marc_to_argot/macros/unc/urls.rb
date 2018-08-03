module MarcToArgot
  module Macros
    module UNC
      module Urls
        include MarcToArgot::Macros::Shared::Urls

        def url(rec, cxt)
          urls = []
          Traject::MarcExtractor.cached("856uy3").each_matching_line(rec) do |field, spec, extractor|
            url = {}
            # only use the FIRST $u value
            url[:href] = collect_subfield_values_by_code(field, 'u').first

            # don't set value if there is no $u
            next if url[:href].nil? || url[:href].empty?

            # set the url type
            url[:type] = url_type_value(field)

            if cxt.clipboard[:shared_record_set] == 'dws'
              url[:text] = dws_url_text
            else
              url[:text] = normal_url_text(field) unless normal_url_text(field).empty?
            end

            urls << url.to_json
          end

          cxt.output_hash['url'] = urls
        end
        
        # assembles a string from the 856 subfields 3 & y to use for the URL text
        # @param field [MARC::DataField] the field to use to assemble URL text
        def normal_url_text(field)
          subfield_values_3 = collect_subfield_values_by_code(field, '3').map { |val| val.strip.sub(/ ?\W* ?$/, '')}
          subfield_values_y = collect_subfield_values_by_code(field, 'y').map { |val| val.strip }

          if subfield_values_y.empty? && url_type_value(field) == 'fulltext'
            subfield_values_y << 'Available via the UNC-Chapel Hill Libraries'
          end

          ([subfield_values_3.join(' ')] + [subfield_values_y.join(' ')]).reject(&:empty?).join(' -- ')
        end

        # Return string for use as URL text in DWS shared records
        def dws_url_text
          'Open Access resource - Full text available'
        end
        
      end
    end
  end
end
