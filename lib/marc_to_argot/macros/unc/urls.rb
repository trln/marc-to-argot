module MarcToArgot
  module Macros
    module UNC
      module Urls
        include MarcToArgot::Macros::Shared::Urls

        def url_unc(rec, cxt)
          urls = []
          Traject::MarcExtractor.cached("856uy3").each_matching_line(rec) do |field, spec, extractor|
            url = {}
            # only use the FIRST $u value
            url[:href] = collect_subfield_values_by_code(field, 'u').first

            # don't set value if there is no $u
            next if url[:href].nil? || url[:href].empty?

            # set the url type
            url[:type] = url_type_value(field)

            # set the text value
            if cxt.clipboard[:shared_record_set]
              url_text = shared_record_url_text(field)
            else
              url_text = normal_url_text(field)
            end
            url[:text] = url_text if url_text

            url[:restricted] = 'false' unless is_restricted?(url[:href])

            # Templatize urls for shared records
            if cxt.clipboard[:shared_record_set] && url[:restricted] == nil
              url[:href] = template_proxy(url[:href])
            end
            
            urls << url.to_json
          end

          cxt.output_hash['url'] = urls unless urls.empty?
        end


        def is_restricted?(url)
          return true if is_proxied?(url)
          return true if url.start_with?('http://unc.kanopystreaming.com')
          return true if url.start_with?('http://vb3lk7eb4t.search.serialssolutions.com')
          return false
        end
        
        # assembles a string from the 856 subfields 3 & y to use for the URL text
        # @param field [MARC::DataField] the field to use to assemble URL text
        def normal_url_text(field)
          subfield_values_y = collect_subfield_values_by_code(field, 'y').map { |val| val.strip }

          if subfield_values_y.empty? && url_type_value(field) == 'fulltext'
            subfield_values_y << 'Available via the UNC-Chapel Hill Libraries'
          end

          ([subfield_values_3(field)] + [subfield_values_y.join(' ')]).reject(&:empty?).join(' -- ')
        end

        # Return string for use as URL text in DWS shared records
        def shared_record_url_text(field)
          sf3 = subfield_values_3(field)
          unless sf3.empty?
            sf3
          end
        end

        def subfield_values_3(field)
          collect_subfield_values_by_code(field, '3').map { |val| val.strip.sub(/ ?\W* ?$/, '')}.join(' ')
        end

        def is_proxied?(url)
          return true if url.start_with?('http://libproxy.lib.unc.edu/login?url=')
          return false
        end

        def template_proxy(url)
          return url.gsub('http://libproxy.lib.unc.edu/login?url=', '{proxyPrefix}')
        end
      end
    end
  end
end
