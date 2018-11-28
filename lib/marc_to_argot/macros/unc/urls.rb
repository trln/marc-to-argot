module MarcToArgot
  module Macros
    module UNC
      module Urls
        include MarcToArgot::Macros::Shared::Urls

        def url_unc(rec, cxt)
          urls = []
          Traject::MarcExtractor.cached("856uy3").each_matching_line(rec) do |field, spec, extractor|
            url = {}
            url[:href] = url_href_value(field)

            # don't set value if there is no $u
            next if url[:href].nil? || url[:href].empty?

            url[:type] = url_type_value(field)

            url_text = url_text(field)
            url_text = "Available via the UNC-Chapel Hill Libraries" if url_text.empty? && url[:type] == 'fulltext'
            url_text = '' if cxt.clipboard[:shared_record_set]
            
            url[:text] = url_text unless url_text.empty?
            url[:note] = url_note(field) unless url_note(field).empty?

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

        def is_proxied?(url)
          return true if url.start_with?('http://libproxy.lib.unc.edu/login?url=')
          return false
        end

        def template_proxy(url)
          return url.gsub('http://libproxy.lib.unc.edu/login?url=', '{+proxyPrefix}')
        end
      end
    end
  end
end
