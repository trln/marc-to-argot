module MarcToArgot
  module Macros
    module Duke
      module Urls
        def url
          data_dir = File.expand_path('../../../data',File.dirname(__FILE__))
          soa_url_conf = YAML.load_file("#{data_dir}/duke/soa_url_conf.yml")

          journal_resource_types = %w[JOURNAL NEWSPAPER]

          # rubocop:disable Metrics/BlockLength
          lambda do |rec, acc, ctx|
            # process MARC 943 fields
            Traject::MarcExtractor.cached('943').each_matching_line(rec) do |field, _spec, _extractor|
              url = {}

              raw_href = collect_and_join_subfield_values(field, 'd').strip

              # UPDATE: We don't really care about the 'q' subfield in
              # determining 'url_type', but
              # we DO care about it when deciding with URL to use
              resource_type = collect_and_join_subfield_values(field, 'q')

              portfolio_id = collect_and_join_subfield_values(field, '8')
              resource_note = collect_and_join_subfield_values(field, 'y').strip

              # For Duke's use of Alma, all 943 fields are considered 'fulltext'
              url[:type] = 'fulltext'
              url[:href] = add_duke_proxy(raw_href, 'fulltext', ctx)
              # override the HREF when subfield 'q' (resource_type) is JOURNAL or NEWSPAPER
              url[:href] = "#{soa_url_conf['soa_url']}#{portfolio_id}" if journal_resource_types.include?(resource_type)

              url[:note] = resource_note unless resource_note.empty?
              url[:restricted] = 'false' unless url_restricted?(raw_href, 'fulltext')
              acc << url.to_json
            end

            # Then process MARC 944 fields
            Traject::MarcExtractor.cached('944').each_matching_line(rec) do |field, _spec, _extractor|
              url = {}
              collection_id = collect_and_join_subfield_values(field, 'b')
              next if collection_id.empty?

              url[:href] = "#{soa_url_conf['soa_url']}#{collection_id}"
              acc << url.to_json
            end

            # Finally, process any holdover (from ALEPH) MARC 856 fields
            Traject::MarcExtractor.cached('856uy3').each_matching_line(rec) do |field, _spec, _extractor|
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
              url[:restricted] = 'false' unless url_restricted?(raw_href, type)
              acc << url.to_json
            end
          end
          # rubocop:enable Metrics/BlockLength
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
          return @unproxied_restricted if defined? @unproxied_restricted

          yaml_data = YAML.load_file(File.expand_path('../../../data/duke/unproxied_restricted.yml', __dir__))
          @unproxied_restricted = yaml_data['domains_and_urls']
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
