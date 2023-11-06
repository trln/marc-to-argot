module MarcToArgot
  module Macros
    module Duke
      module Urls
        def url
          lambda do |rec, acc, ctx|
            Traject::MarcExtractor.cached("856uy3").each_matching_line(rec) do |field, spec, extractor|
              url = {}
              raw_href = url_href_value(field)

              next if raw_href.nil? || raw_href.empty?

              type = url_type_value(field)
              text = url_text(field)
              note = url_note(field)

              url[:href] = add_duke_proxy(raw_href, type, ctx)
              url[:type] = type
              url[:text] = text unless text.empty?
              url[:note] = note unless note.empty?
              url[:restricted] = url_restricted?(raw_href, type) ? 'true' : 'false'
              acc << url.to_json
            end
          end
        end

        def url_href_value(field)
          [collect_subfield_values_by_code(field, 'u').first,
           collect_subfield_values_by_code(field, 'a').first].compact.reject(&:empty?).first
        end

        # assembles a string from the 856 subfields y to use for the URL text
        # @param field [MARC::DataField] the field to use to assemble URL text
        def url_text(field)
          subfield_values_y = collect_subfield_values_by_code(field, 'y')
          [subfield_values_y.join(' ')].reject(&:empty?)
                                       .reject { |v| v.match(/get\s*it@duke/i) }
                                       .join(' ')
        end

        # NOTE: Proxy prefix is now added to 856 field in Aleph
        #       and no longer added here as part of the data pipeline.
        #       Continue to add the proxy placeholder for shared records.
        #       Remove Duke proxy prefix from shared records.
        def add_duke_proxy(href, type, ctx)
          if type == 'fulltext' &&
             ctx.clipboard.fetch(:shared_record_set, '').match(/\S/) &&
             url_restricted?(href, type)
            "{+proxyPrefix}#{href.gsub(%r{http(s)?://(login.)?proxy\.lib\.duke\.edu/login\?url=}, '')}"
          else
            # Send the full href, ensuring we have the correct proxy prefix.
            # It's possible some older cataloged items have Duke's old proxy prefix.
            href.gsub(%r{http(s)?://proxy\.lib\.duke\.edu}, 'https://login.proxy.lib.duke.edu')
          end
        end

        # This idea is borrowed from UNC
        # Domains or substrings for URLs that are not proxied but are
        # nevertheless restricted to Duke affiliates (via Shib/SSO)
        def unproxied_restricted
          %w[scifinder.cas.org
             sciencedirect.com
             osapublishing.org
             escj.org
             nature.com
             scientificamerican.com
             link.springer.com
             journals.iop.org
             www.elr.info/about-elr
             traditiononline.org/my-account
             go.oreilly.com
             aapgbulletin.datapages.com
             library.fuqua.duke.edu/databases/zephyr-info.htm
             library.fuqua.duke.edu/databases/orbis-info.htm
             zephyr.bvdinfo.com]
        end

        def url_restricted?(href, type)
          url = href.downcase
          return true if unproxied_restricted.select { |e| url.include?(e) }.any?
          return true if type == 'fulltext' && url.include?('proxy.lib.duke.edu')

          false
        end

        # tests whether the field contains a URL for a finding aid
        # @param field [MARC::DataField] the field to check for a finding aid URL
        def url_for_finding_aid?(field)
          substring_present_in_subfield?(field, 'u', 'library.duke.edu/rubenstein/findingaids') ||
            substring_present_in_subfield?(field, 'u', 'scriptorium.lib.duke.edu/dynaweb/findaids') ||
            substring_present_in_subfield?(field, 'u', 'library.duke.edu/digitalcollections/rbmscl') ||
            substring_present_in_subfield?(field, 'y', 'collection guide') ||
            substring_present_in_subfield?(field, '3', 'collection guide') ||
            substring_present_in_subfield?(field, 'y', 'finding aid') ||
            substring_present_in_subfield?(field, '3', 'finding aid')
        end
      end
    end
  end
end
