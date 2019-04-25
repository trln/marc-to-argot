module MarcToArgot
  module Macros
    module UNC
      module FindingAid
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
          if has_nps_id?(rec)
          else
            
          end
        end

        def get_finding_aid_urls(rec)
          url_fields = rec.find_all { |f| f.tag == '856' && f.indicator1 == '4' &&
                                      f.indicator2 == '2' &&
                                      f['u'] =~ /https?:\/\/finding-aids\.lib\.unc\.edu\/[0-9A-Z]/ }
          urls = url_fields.map { |f| f['u'] }
          urls
        end
        
      end
    end
  end
end
