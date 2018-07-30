module MarcToArgot
  module Macros
    module NCCU
      # Methods for working with NCCU item records
      module Items
        SUBFIELDS = {
          i: { key: 'item_id' },
          c: { key: 'copy_no' },
          m: { key: 'loc_b' },
          o: { key: 'notes' },
          a: { key: 'call_no' },
          k: { key: 'loc_current' },
          l: { key: 'loc_n' },
          t: { key: 'type' },
          v: { key: 'vol' },
          w: { key: 'cn_scheme' },
          z: { key: 'item_cat_2' }
        }.freeze

        LOCATION_AVAILABILITY = {
          "AVAIL_SOON" => "Available",
          "BINDERY" => "Not Available",
          "CHECKEDOUT" => "Checked Out",
          "DISCARD" => "Not Available", #Check with NCCU what to display
          "EASY" => "Available", #Check with NCCU what to display
          "HOLDS" => "On Hold", 
          "ILL" => "Not Available", 
          "ILLNCIP" => "Not Available", 
          "INPROCESS" => "Available", 
          "INSHIPPING" => "Checked Out", 
          "INTRANSIT" => "Available",
          "LAWDISPLAY" => "Available", #Check with NCCU what to display
          "LONGOVRDUE" => "Not Available",
          "LOST" => "Lost", 
          "LOST-ASSUM" => "Lost",
          "LOST-CLAIM"  => "Lost", 
          "MISSING" => "Lost", 
          "ON-ORDER" => "Available", 
          "REPAIR" => "Not Available", 
          "RESHELVING" => "Available", 
          "REVIEWME"  => "Not Available", 
          "RESERVES" => "Available - Library Use Only",  
          "SERIALS" => "Available - Library Use Only",
          "TUCKER" => "Available - Library Use Only", #Check with NCCU what to display. I assume this is a special collection
          "MCKISSICK" => "Available",
          "SCORES" => "Available", #When the records fixed, this value can be deleted
          "STACKS" => "Available",  
          "WITHDRAWN" =>  "Not Available",
          "MEDIA" => "Available ",  
          "REFDISPLAY" => "Available - Library Use Only", 
          "REFERENCE" => "Available - Library Use Only" 
         }.freeze 

        def get_location(item)
          [item['loc_b'], item['loc_n']]
        end

        def item_status(current, home)
          location_status = LOCATION_AVAILABILITY.fetch(
            current,
            case current
            when /^RSRV/
              'Available - On Reserve'
            end
          )

          simple_status = 'Available' if current.nil? || current.empty? || current == home

          if location_status.nil?
            simple_status || "Unknown - #{current}"
          else
            location_status
          end
        end

        # computes and updates item status
        def item_status!(item)
          item['status'] = item_status(item.fetch('loc_current', ''), item['loc_n'])
        end

        def marc_to_item(field)
          item = {}
          field.subfields.each do |subfield|
            code = subfield.code.to_sym
            mapped = SUBFIELDS.fetch(code, key: nil)[:key]
            item[mapped] = subfield.value unless mapped.nil?
          end
          item_status!(item)
          item
        end

        # writes various values into the context once all the items
        # for a record have been gathered.
        def populate_context!(items, rec, ctx)
          ctx.clipboard['items'] = items
          libs = items.map { |x| x['loc_b'] }
          access_types = []
          access_types << 'Online' if online_access?(rec, libs)
          access_types << 'At the Library' if physical_access?(rec, libs)
          ctx.output_hash['access_type'] = access_types
          ctx.output_hash['available'] = 'Available' if is_available?(items)
          locations = map_locations_to_hierarchy(items)
          ctx.output_hash['location_hierarchy'] =  arrays_to_hierarchy(locations) if locations
        end

        def map_locations_to_hierarchy(items)
          locations = ['nccu']
          items.each do |item|
            loc_b = item.fetch('loc_b', nil)
            loc_n = item.fetch('loc_n', nil)
            loc_n = loc_b + loc_n
            locations << location_hierarchy_map[loc_b] if loc_b
            locations << location_hierarchy_map[loc_n] if loc_n
          end

          locations.map { |loc| loc.split('|') if loc }.flatten.map { |c| c.split(';') if c }.compact
        end

        def extract_items
          lambda do |rec, acc, ctx|
            items = []
            Traject::MarcExtractor.cached('999', alternate_script: false).each_matching_line(rec) do |field, _s, _e|
              item = marc_to_item(field)
              items << item
              acc << item.to_json if item
            end
            populate_context!(items, rec, ctx)
            map_call_numbers!(ctx, items)
          end
        end

        def location_hierarchy_map
         @location_hierarchy_map ||= Traject::TranslationMap.new('nccu/location_hierarchy')
        end

        def is_available?(items)
          items.any? { |i| i['status'].downcase.start_with?('available') rescue false }
        end

      end
    end
  end
end
