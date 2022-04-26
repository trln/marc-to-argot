module MarcToArgot
  module Macros
    module UNC
      module FindingAid
        def set_ead_id(rec, cxt)
          id = case finding_aid_enhanceable?(rec)
               when 'ead'
                 get_finding_aid_id(rec)
               when 'nps'
                 get_nps_id(rec)
               end
          return unless id

          idhash = {'value' => "UNC FA #{id}",
                    'display' => 'false',
                    'type' => 'Finding aid ID'}

          if cxt.output_hash.has_key?('misc_id')
            cxt.output_hash['misc_id'] << idhash
          else
            cxt.output_hash['misc_id'] = [idhash]
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
          true if get_finding_aid_id(rec)
        end

        def has_nps_id?(rec)
          true if get_nps_id(rec)
        end

        def get_finding_aid_id(rec)
          url = get_finding_aid_urls(rec).first
          return unless url

          url.sub('https://finding-aids.lib.unc.edu/', '').gsub('/', '')
        end

        def get_nps_id(rec)
          id_fields = rec.find_all { |f| f.tag == '919' && f.indicator1 == '0' &&
                                      f.indicator2 == ' ' &&
                                     f['a'] =~ /^nps/ }
          return if id_fields.empty?

          id_fields.first['a']
        end

        def get_finding_aid_urls(rec)
          url_fields = rec.find_all { |f| f.tag == '856' && f.indicator1 == '4' &&
                                      f.indicator2 == '2' &&
                                      f['u'] =~ /https?:\/\/finding-aids\.lib\.unc\.edu\/[0-9A-Za-z]/ }
          urls = url_fields.map { |f| f['u'].sub('http:', 'https:') }
          urls
        end
      end
    end
  end
end
