module MarcToArgot
  module Macros
    module UNC
      module FindingAid
        require 'open-uri'
        def set_ead_id(rec, cxt)
          id = get_finding_aid_id(rec) if finding_aid_enhanceable?(rec) == 'ead'
          if id
          idhash = {'value' => "UNC FA #{id}",
                    'display' => 'false',
                    'type' => 'Finding aid ID'}

          if cxt.output_hash.has_key?('misc_id')
            cxt.output_hash['misc_id'] << idhash
          else
            cxt.output_hash['misc_id'] = [idhash]
          end
          end
        end
        
        def finding_aid_enhanceable?(rec)
          return 'nps' if has_nps_id?(rec)
          return 'ead' if collection_or_subunit?(rec) &&
                          has_finding_aid_url?(rec)
        end

        def collection_or_subunit?(rec)
          blvl = rec.leader[7]
          return true if %w[c d].include?(blvl)
        end

        def has_finding_aid_url?(rec)
          the856s = rec.find_all { |f| f.tag == '856' && f.indicator1 == '4' &&
                                   f.indicator2 == '2' &&
                                   f['u'] =~ /https?:\/\/finding-aids\.lib\.unc\.edu\/[0-9A-Z]/ }
          return true if the856s.length > 0
        end

        def has_nps_id?(rec)
          id_field = rec.find_all { |f| f.tag == '919' &&
                                    f.indicator1 == '0' &&
                                    f['a'].start_with?('nps')
          }
          return true if id_field.length > 0
        end

        def get_finding_aid_id(rec)
          url = get_finding_aid_urls(rec).first
          return url.sub('https://finding-aids.lib.unc.edu/', '').gsub('/', '')
        end

        def get_nps_id(rec)
          id_fields = rec.find_all { |f| f.tag == '919' && f.indicator1 == '0' &&
                                      f.indicator2 == ' ' &&
                                     f['a'] =~ /^nps/ }
          id_fields.first['a']
        end

        def get_finding_aid_urls(rec)
          url_fields = rec.find_all { |f| f.tag == '856' && f.indicator1 == '4' &&
                                      f.indicator2 == '2' &&
                                      f['u'] =~ /https?:\/\/finding-aids\.lib\.unc\.edu\/[0-9A-Z]/ }
          urls = url_fields.map { |f| f['u'].sub('http:', 'https:') }
          urls
        end

        def get_ead_uri(id)
          "https://finding-aids.lib.unc.edu/ead/#{id}.xml"
        end

        def get_ead(id)
          Nokogiri::XML(open(get_ead_uri(id)),&:noblanks)
        end

        def get_biog_hist_note(ead)
          biog = ead.xpath("/ead/archdesc/bioghist/*")
          unless biog.empty?
            bnote = []
            #discard head node
            biog = biog.reject { |n| n.name == 'head' }
            biog.each do |n|
              bnote << n.text if n.name == 'p'
            end
            bnote
          end
        end
      end
    end
  end
end
