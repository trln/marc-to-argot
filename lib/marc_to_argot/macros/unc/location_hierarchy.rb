module MarcToArgot
  module Macros
    module UNC
      module LocationHierarchy

        def location_hierarchy(rec, cxt)
          out = cxt.output_hash
          item_locs = get_loc_codes(out['items']) if out['items']
          item_locs = [] unless item_locs

          holding_locs = get_loc_codes(out['holdings']) if out['holdings']
          holding_locs = [] unless holding_locs

          locs = item_locs + holding_locs
          locs = locs.compact.uniq
          
          hier_locs = locs.map{ |loc| loc_hierarchy_map[loc] }.flatten
          hier_locs = hier_locs.compact
          
          if hier_locs.length > 0
            cxt.output_hash['location_hierarchy'] = explode_hierarchical_strings(hier_locs)
          end
        end

        private

        def get_loc_codes(i_or_h)
          to_j = i_or_h.map{ |e| JSON.parse(e) }
          codes = to_j.map{ |e| e['loc_b'] }
          codes = codes.reject{ |c| c == 'unknown'}
          return codes.compact if codes.length > 0
        end

        def loc_hierarchy_map
          @loc_hierarchy_map ||=Traject::TranslationMap.new('unc/loc_b_to_hierarchy')
        end

      end
    end
  end
end 
