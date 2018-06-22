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

        MAINS = Set.new(%w[DHILL HUNT]).freeze

        # locations that map to virtual collections
        # library does not matter for these, EXCEPT for LRL/TEXTBOOK
        # which is not part of the
        LOC_COLLECTIONS = Set.new(%w[TEXTBOOK FLOATGAME FLOATDVD PRAGUE]).freeze

        LOCATION_AVAILABILITY = {
          'CHECKEDOUT' => 'Checked Out',
          'ILL' => 'Checked Out',
          'ON-ORDER' => 'On Order',
          'INPROCESS' => 'Received - In Process',
          'RESERVES' => 'Available - On Reserve',
          'INTRANSIT' => 'Being transferred between libraries',
          'BINDERY' => 'Material at the bindery',
          'REPAIR' => 'Being fixed/mended',
          'PRESERV' => 'Preservation',
          'RESHELVING' => 'Just retruned',
          'CATALOGING' => 'In Process'
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
            map_call_numbers(ctx, items)
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
