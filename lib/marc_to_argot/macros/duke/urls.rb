module MarcToArgot
  module Macros
    module Duke
      # Add a 'url' hash to the data "accumalator"
      module Urls
        def url
          data_dir = File.expand_path('../../../data',File.dirname(__FILE__))
          soa_url_conf = YAML.load_file("#{data_dir}/duke/soa_url_conf.yml")
          journal_resource_types = YAML.load_file("#{data_dir}/duke/valid_journal_types.yml")

          # rubocop:disable Metrics/BlockLength
          lambda do |rec, acc, ctx|
            # process MARC 943 fields

            # create some preliminary variables we'll use when 
            # 943 fields are present.
            alma_number = alma_number_for_rec(rec)
            ctx.output_hash['alma_number'] = alma_number unless alma_number.nil?

            journals_present = false
            resources = []

            ctx.clipboard[:urls_sent] ||= []
            
            # iterate over all known 943 fields, flipping the "journals_present" flag when a
            # 'journal_resource_type' is detected
            Traject::MarcExtractor.cached('943').each_matching_line(rec) do |field, _spec, _extractor|
              # inspect 943$s, moving to the next field if s = "Not Available"
              label = collect_and_join_subfield_values(field, 's').strip
              next if label.downcase.eql? 'not available'

              resource_type = collect_and_join_subfield_values(field, 'q')
              resources << field
              journal_resource_types.include?(resource_type) && journals_present = true
            end
            # We found 943 field(s) and we'll craft the url here.
            unless resources.empty?
              url = {}
              url[:marc_source] = '943'
              url[:type] = 'fulltext'
              if resources.length > 1
                # create one url entry using soa_url with identifier appended
                identifier = (alma_number && !alma_number.empty?) ? alma_number : extract_portfolio_id_from_resources(resources)
                if identifier
                  url[:href] = "#{soa_url_conf['soa_url']}#{identifier}"
                  # Add portfolio_id to the URL data for test compatibility
                  url[:portfolio_id] = identifier unless alma_number
                end
              else
                if journals_present
                  identifier = (alma_number && !alma_number.empty?) ? alma_number : extract_portfolio_id_from_resource(resources.first)
                  if identifier
                    url[:href] = "#{soa_url_conf['soa_url']}#{identifier}"
                    # Add portfolio_id to the URL data for test compatibility
                    url[:portfolio_id] = identifier unless alma_number
                  end
                else
                  raw_href = collect_and_join_subfield_values(resources.first, 'd').strip
                  url[:href] = add_duke_proxy(raw_href, 'fulltext', ctx)
                end
              end
              
              # Only add the URL if we have a valid href
              if url[:href] && !url[:href].empty?
                url[:restricted] = 'false' unless url_restricted?(url[:href], 'fulltext')
                acc << url.to_json
                ctx.clipboard[:urls_sent] << url
              end
            end
            ## end of MARC 943 section ##

            # (Jun 18, 2025 -- AK-492)
            # For these next two logic blocks, we need to verify the "url" is empty
            # Attempt to create a "url" entry from either the (newer) 944 field 
            # or the (older -- ALEPH) 856 field
            # -------

            # There are no 943 fields present when 944 fields exists
            # I believe this is a rare case, but must be accounted for.
            if ctx.clipboard[:urls_sent].empty? || resources.empty?
              Traject::MarcExtractor.cached('944').each_matching_line(rec) do |field, _spec, _extractor|
                collection_id = collect_and_join_subfield_values(field, 'b').strip
                next if collection_id.empty?

                url = {}
                url[:href] = "#{soa_url_conf['soa_url']}#{collection_id}"
                url[:restricted] = 'false' unless url_restricted?(url[:href], 'fulltext')
                url[:marc_source] = '944'
                acc << url.to_json
                ctx.clipboard[:urls_sent] << url
              end
            end

            # Finally, process any holdover (from ALEPH) MARC 856 fields
            # ONLY WHEN urls_sent is (still) empty -- meaning, the record didn't have 
            # any 943 fields or (rare case) 944 fields
            if ctx.clipboard[:urls_sent].empty?
              Traject::MarcExtractor.cached('856uy3').each_matching_line(rec) do |field, _spec, _extractor|
                url = {}
                raw_href = url_href_value(field)

                next if raw_href.nil? || raw_href.empty?

                type = url_type_value(field)
                text = url_text(field)
                note = url_note(field)

                url[:marc_source] = '856'
                url[:href] = add_duke_proxy(raw_href, type, ctx)
                url[:type] = type
                url[:text] = text unless text.empty?
                url[:note] = note unless note.empty?
                url[:restricted] = 'false' unless url_restricted?(raw_href, type)
                acc << url.to_json
              end
            end
          end
          # rubocop:enable Metrics/BlockLength
        end

        # soa_url_for_rec - assemble an soa_url for "rec" from its 941e subfield
        def alma_number_for_rec(rec)
          iee_subfield = rec.fields.select { |f|
            next unless f.tag == '941'

            !f.subfields.select { |s| s.code == 'e' }.empty?
          }.first
          collect_and_join_subfield_values(iee_subfield, 'e') unless iee_subfield.nil?
        end

        # Extract portfolio ID from a single MARC 943 resource field
        # This is used as a fallback when alma_number is not available
        def extract_portfolio_id_from_resource(resource)
          raw_href = collect_and_join_subfield_values(resource, 'd').strip
          return nil if raw_href.empty?
          
          # Extract portfolio_pid from URLs like:
          # https://na05-psb.alma.exlibrisgroup.com/view/uresolver/01DUKE_INST/openurl?u.ignore_date_coverage=true&portfolio_pid=53896265270008501&Force_direct=true
          match = raw_href.match(/portfolio_pid=([^&]+)/)
          match ? match[1] : nil
        end

        # Extract portfolio ID from multiple MARC 943 resource fields
        # For multiple resources, use the first available portfolio ID
        def extract_portfolio_id_from_resources(resources)
          resources.each do |resource|
            portfolio_id = extract_portfolio_id_from_resource(resource)
            return portfolio_id if portfolio_id
          end
          nil
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
