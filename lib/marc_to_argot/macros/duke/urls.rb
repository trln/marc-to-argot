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

            # iterate over all known 943 fields, tripping the "journals_present" flag when a
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
            url = {}
            unless resources.empty?
              url[:marc_source] = '943'
              url[:type] = 'fulltext'
              if resources.length > 1
                # create one url entry using soa_url with alma_number appended
                url[:href] = "#{soa_url_conf['soa_url']}#{alma_number}"
              else
                url[:href] = "#{soa_url_conf['soa_url']}#{alma_number}" if journals_present
                unless journals_present
                  raw_href = collect_and_join_subfield_values(resources.first, 'd').strip
                  url[:href] = add_duke_proxy(raw_href, 'fulltext', ctx)

                  # we'll capture this 'raw_href' and use it in the rspec that 
                  # verifies the the value in 943d is included in url['href']
                  tmp_hash = {}
                  tmp_hash['raw_href'] = raw_href
                  ctx.output_hash['943d'] = tmp_hash.to_json
                end
              end
              url[:restricted] = 'false' unless url_restricted?(url[:href], 'fulltext')
              acc << url.to_json
            end
            ## end of MARC 943 section ##

            # There are no 943 fields present when 944 fields exists
            # I believe this is a rare case, but must be accounted for.
            Traject::MarcExtractor.cached('944').each_matching_line(rec) do |field, _spec, _extractor|
              url = {}
              collection_id = collect_and_join_subfield_values(field, 'b').strip
              next if collection_id.empty?

              url[:href] = "#{soa_url_conf['soa_url']}#{collection_id}"
              url[:restricted] = 'false' unless url_restricted?(url[:href], 'fulltext')
              url[:marc_source] = '944'
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

              url[:marc_source] = '856'
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

        # soa_url_for_rec - assemble an soa_url for "rec" from its 941e subfield
        def alma_number_for_rec(rec)
          iee_subfield = rec.fields.select { |f|
            next unless f.tag == '941'

            !f.subfields.select { |s| s.code == 'e' }.empty?
          }.first
          collect_and_join_subfield_values(iee_subfield, 'e') unless iee_subfield.nil?
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
