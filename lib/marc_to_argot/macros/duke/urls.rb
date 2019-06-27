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
              url[:restricted] = 'false' unless url_restricted?(raw_href, type)

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

        def add_duke_proxy(href, type, ctx)
          if type == 'fulltext' &&
            ctx.clipboard.fetch(:shared_record_set, false).present? &&
            url_restricted?(href, type)
            "{+proxyPrefix}#{href}"
          elsif type == 'fulltext' &&
            url_restricted?(href, type) &&
            !href.match(/proxy\.lib\.duke\.edu.*url=/)
            "https://proxy.lib.duke.edu/login?url=#{href}"
          else
            href
          end
        end

        def url_restricted?(href, type)
          exception_matches = open_access_exceptions.select { |e| href.match(e) }.any?
          return false if (href.match(/(\.edu)|(\.gov)/) &&
                          !exception_matches && type == 'fulltext') ||
                          href.match(/repository\.duke\.edu\/dc/)
          true
        end

        def open_access_exceptions
          %w[catdir
             metasearch
             journals.uchicago
             humanities.uchicago
             getitatduke
             duke.edu
             .com
             ARTFL
             artfl-project.uchicago.edu
             stephanus.tlg.uci.edu
             ropercenter.cornell.edu
             vha.usc.edu
             bmc.lib.umich.edu
             rotunda.upress.virginia.edu
             quod.lib.umich.edu
             muse.jhu.edu
             press.jhu.edu
             ica1.princeton.edu
             hapi.gseis.ucla.edu
             ets.umdl.umich.edu
             ehrafworldcultures.yale.edu
             ccrd.usc.cuhk.edu.hk
             woolf-center.southernct.edu
             theindex.princeton.edu
             prde.upress.virginia.edu
             hapi.ucla.edu]
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

        # NOTE: I'm leaving these methods here for future use,
        # but at the moment we have copyright issues
        # that prevent us from linking directly to some of
        # these records in IA.

        def internet_archive_arks
          lambda do |rec, acc, ctx|
            Traject::MarcExtractor.cached("955bz").each_matching_line(rec) do |field|
              links = {}
              ark = field.subfields.select { |sf| sf.code == 'b' }.map(&:value).first
              copy = field.subfields.select { |sf| sf.code == 'z' }.map(&:value).first
              links[:ark] = ark unless ark.nil? || ark.empty?
              links[:copy] = copy unless copy.nil? || copy.empty?
              acc << links unless links.empty?
            end
          end
        end

        def add_internet_archive_links(ctx)
          if ctx.output_hash.key?('internet_archive_arks') &&
             !ctx.output_hash.fetch('access_type', []).include?('Online')
            ctx.output_hash['url'] ||= []
            ctx.output_hash['internet_archive_arks'].each do |ia|
              copy = ia.fetch(:copy, '').strip
              ark = ia.fetch(:ark, '').strip
              url = {}
              url[:href] = "https://n2t.net/#{ark}" unless ark.empty?
              url[:type] = 'fulltext'
              url[:note] = copy unless copy.empty?
              url[:restricted] = 'false'
              ctx.output_hash['url'] << url.to_json unless ark.empty?
            end
            ctx.output_hash['access_type'] << 'Online'
          end
          ctx.output_hash.delete('internet_archive_arks')
        end
      end
    end
  end
end
