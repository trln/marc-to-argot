module MarcToArgot
  module Macros
    module NCSU
      # Methods for working with NCSU item records
      module Items
        SUBFIELDS = {
          i: { key: 'item_id' },
          # c: { key: 'copy_no' },
          m: { key: 'loc_b' },
          # o: { key: 'notes' },
          a: { key: 'call_no' },
          k: { key: 'loc_current' },
          l: { key: 'loc_n' },
          t: { key: 'type' },
          v: { key: 'vol' },
          w: { key: 'cn_scheme' },
          z: { key: 'item_cat_2' }
        }.freeze

        NO_FACET_LOCATIONS = %w[ONLINE BBR].freeze

        MAINS = Set.new(%w[DHHILL HUNT BOOKBOT]).freeze

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
          'RESHELVING' => 'Just returned',
          'CATALOGING' => 'In Process',
          'HOLDS' => 'On hold for another user'
        }.freeze

        #not currently used, but could be helpful in the future
        OFFSITE_SPEC_COLLECTIONS = Set.new(%w[ARCHIVES STACKS METCALF SPEC SPEC-OD MANUSCRIPT
                                   AUCTIONCAT PRESERV MAPS OVERSIZE OVERSIZE2 FACULTYPUB
                                   REF-OVER MICROFORMS SATELLITE SAT-OV SAT-OV2 SMALLBOOK]).freeze

        SPEC_COLL_NOT_REQUESTABLE = Set.new(%w[EXHIBITS REF FACPUBS-RR]).freeze

        OFFSITE_LIB = Set.new(%w[DUKELSC SATELLITE BOOKBOT]).freeze


        def shadowed_location?(item)
          %w[BOTMISSING ACQ-S MISSING].include?(item['loc_n'])
        end

        def virtual_collection(item)
          item['loc_b'] != 'LRL' && LOC_COLLECTIONS.include?(item['loc_n']) && item['loc_n']
        end

        def get_location(item)
          [item['loc_b'], item['loc_n']]
        end

        # FOURTHFLOORCLOSURE
        def hill_fourth_floor?(item)
          cn = item.fetch('call_no', '')
          item['loc_b'] == 'DHHILL' && item['loc_n'] == 'STACKS' && ( 'A' <= cn &&cn <= 'DB' )
        end

        # Offsite & requestable
        def offsite?(item)
          return true if OFFSITE_LIB.include?(item['loc_b']) || hill_fourth_floor?(item)

          case item['loc_b']
          when 'SPECCOLL'
            return true unless SPEC_COLL_NOT_REQUESTABLE.include?(item['loc_n'])
          end
          false
        end

        def reserve?(item)
          return true if item['type'] == 'COREBOOK' && item['loc_n'] == 'TEXTBOOK'

          false
        end

        def kindle?(item)
          return true if item['type'] == 'EBOOK' && item['loc_b'] != 'ONLINE'

          false
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
            # dup because otherwise we potentially modify the copy that's stored
            # in the LOCATION_AVAILABILITY hash
            location_status.dup
          end
        end

        # items in certain 'current' locations
        # should be displayed as if that is their
        # home location
        def current_as_home?(loc)
          case loc
          when 'RESERVES'
            true
          when /^RSRV-/
            true
          when 'NEWBOOKS'
            true
          else
            false
          end
        end

        def remap_item_locations!(item)
          lib, loc = get_location(item)
          if lib == 'BOOKBOT'
            item['loc_b'] = 'HUNT'
            item['loc_n'] = 'BOOKBOT'
          end
          item['loc_b'] = 'BBR' if loc == 'PRINTDDA' && lib == 'DHHILL'
          item['loc_n'] = "SPECCOLL-#{loc}" if lib == 'SPECCOLL'

          # reserves should pretend they're home.
          if current_as_home?(item['loc_current'])
            item['loc_n'] = item['loc_current']
          end
          # now some remappings based on item type
          item['loc_n'] = 'GAME' if item['type'] == 'GAME-4HR'
        end

        def library_use_only?(item)
          lib, loc = get_location(item)
          lib_cases = lib == 'SPECCOLL'
          loc_cases = case loc
                      when 'GAMELAB', /^VR/, /^SPEC/, /^REF/
                        true
                      else
                        false
                      end
          type_cases = case item['type']
                       when 'SERIAL'
                        # Hill, Hunt circulate; others do not
                         !MAINS.include?(lib)
                       when 'BOOKNOCIRC', 'MAP', 'CD-ROM-NC'
                         true
                       else
                         false
                       end

          lib_cases || loc_cases || type_cases
        end

        # computes and updates item status
        def item_status!(item)
          item['status'] = item_status(item.fetch('loc_current', ''), item['loc_n'])
          if item['status'] == 'Available'
            if offsite?(item)
              item['status'] = 'Available upon request'
            elsif reserve?(item)
              item['status'] = 'Available - On Reserve'
            elsif kindle?(item)
              item['status'] = 'Available - Libraries Kindle only'
            end
          end
          item['status'] = item['status'] + ' (Library use only)' if library_use_only?(item)
        end

        def marc_to_item(field)
          item = {}
          field.subfields.each do |subfield|
            code = subfield.code.to_sym
            mapped = SUBFIELDS.fetch(code, key: nil)[:key]
            item[mapped] = subfield.value unless mapped.nil?
          end
          item['copy_no'] = ''
          item['call_no'] = '' if item.fetch('call_no','').downcase.start_with?('xx')
          item_status!(item)
          item
        end

        # writes various values into the context once all the items
        # for a record have been gathered.
        def populate_context!(items, rec, ctx)
          ctx.clipboard['items'] = items
          libs = items.map { |x| x['loc_b'] }
          vcs = items.map { |x| virtual_collection(x) }.select(&:itself).uniq
          access_types = []
          access_types << 'Online' if online_access?(rec, libs)
          access_types << 'At the Library' if physical_access?(rec, libs)
          ctx.output_hash['access_type'] = access_types
          ctx.output_hash['virtual_collection'] = vcs unless vcs.empty?
          visible_loc_items = items.reject { |i| NO_FACET_LOCATIONS.include?(i['loc_b']) }
          loc_hier = arrays_to_hierarchy(visible_loc_items.map { |x| ['ncsu', x['loc_b']] })
          loc_hier << 'hsl' << 'hsl:hslncsuvetmed' if visible_loc_items.any? { |i| i['loc_b'] == 'VETMED' }
          ctx.output_hash['location_hierarchy'] = loc_hier
        end

        def extract_items
          lambda do |rec, acc, ctx|
            items = []
            Traject::MarcExtractor.cached('999', alternate_script: false).each_matching_line(rec) do |field, _s, _e|
              item = marc_to_item(field)
              remap_item_locations!(item)
              unless shadowed_location?(item)
                items << item 
                acc << item.to_json if item 
              end
            end
            items = MarcToArgot::Macros::NCSU::ItemUtils.sort_items(items)
            populate_context!(items, rec, ctx)
            map_call_numbers!(ctx, items)
          end
        end
      end
    end
  end
end
