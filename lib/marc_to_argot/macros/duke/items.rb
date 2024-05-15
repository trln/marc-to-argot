module MarcToArgot
  module Macros
    module Duke
      module Items
        ################################################
        # Items
        ######

        def extract_items
          lambda do |rec, acc, ctx|
            lcc_top = Set.new
            items = []
            barcodes = []
            shelf_numbers = []
            lc_call_nos_normed = []

            Traject::MarcExtractor.cached('940', alternate_script: false)
                                  .each_matching_line(rec) do |field, spec, extractor|
              item = {}

              field.subfields.each do |subfield|
                sf_code = subfield.code
                case sf_code
                when 'b'
                  item['loc_b'] = subfield.value.strip
                when 'c'
                  item['loc_n'] = subfield.value.strip
                when 'd'
                  item['cn_scheme'] = subfield.value.strip
                when 'h'
                  item['call_no'] = subfield.value
                when 'n'
                  item['copy_no'] = subfield.value
                when 'o'
                  item['status_code'] = subfield.value
                when 'p'
                  item['item_id'] = subfield.value.strip
                  barcodes << subfield.value.strip
                when 'q'
                  item['process_state'] = subfield.value
                when 'r'
                  item['type'] = subfield.value
                when 'x'
                  item['due_date'] = subfield.value
                when 'z'
                  item['notes'] ||= []
                  item['notes'] << subfield.value
                end
              end

              item['status'] = ItemStatus.set_status(rec, item)

              # Add all normalized LC Call Nos to lc_call_nos_normed field
              # for searching.
              # And add all shelving control numbers
              # to shelf_numbers for searching.
              case item.fetch('cn_scheme', '')
              when '0'
                lc_call_nos_normed << Lcsort.normalize(item.fetch('call_no', '').strip)
              when '4'
                if item.fetch('loc_b', '') != 'SCL'
                  shelf_numbers << item.fetch('call_no', '').strip
                end
              end

              # Now we convert our Aleph numeric codes to
              # TRLN Discovery ALPHA codes
              if item.fetch('call_no', nil) && item.fetch('cn_scheme', nil)
                case item.fetch('cn_scheme', '')
                when '0'
                  item['cn_scheme'] = 'LC'
                  lcc_top.add(item.fetch('call_no', '')[0, 1])
                when '1'
                  item['cn_scheme'] = 'DDC'
                when '2'
                  item['cn_scheme'] = 'NLM'
                when '3'
                  item['cn_scheme'] = 'SUDOC'
                when '4', '5', '6', '7', '8'
                  item['cn_scheme'] = 'ALPHANUM'
                else
                  item.delete('cn_scheme')
                end
              else
                item.delete('cn_scheme')
              end

              item.delete('process_state')
              item.delete('status_code')
              item.delete('due_date')

              unless online_item?(item) # Filter out online items.
                items << item
                # Save physical items to clipboard for use later.
                ctx.clipboard[:physical_items] ||= []
                ctx.clipboard[:physical_items] << item
              end
            end

            if items.length > 1
              normed = items.map do |i|
                [NormalizeCallNumber.normalize_cn_and_copy_info("#{i.fetch('call_no', '')} #{i.fetch('copy_no', '')}"), i]
              end
              normed.sort_by! { |x| x[0] }
              sorted_items = normed.map { |x| x[1] }
              acc.concat(sorted_items.map(&:to_json))
            else
              acc.concat(items.map(&:to_json))
            end

            locations = LocationMap.map_locations_to_hierarchy(items)

            ctx.output_hash['lcc_top'] = lcc_top.to_a
            ctx.output_hash['available'] = 'Available' if ItemStatus.is_available?(items)
            ctx.output_hash['location_hierarchy'] = arrays_to_hierarchy(locations) if locations
            ctx.output_hash['barcodes'] = barcodes if barcodes.any?
            ctx.output_hash['shelf_numbers'] = shelf_numbers.uniq.compact if shelf_numbers.any?
            ctx.output_hash['lc_call_nos_normed'] = lc_call_nos_normed.uniq.compact if lc_call_nos_normed.any?

            map_call_numbers!(ctx, items)
          end
        end

        def online_item?(item)
          item['loc_b'] == 'DUKIR' ||
          item['loc_b'] == 'ONLINE' ||
          item['loc_b'] == '' ||
          item['loc_n'] == 'PEI' ||
          item['loc_n'] == 'FRDE' ||
          item['loc_n'] == 'PENTL' ||
          item['loc_n'] == 'MELEC' ||
          item['loc_n'] == 'LINRE' ||
          item['loc_n'] == 'database'
        end

        ################################################
        # Holdings
        ######

        def extract_holdings
          lambda do |rec, acc, ctx|
            Traject::MarcExtractor.cached('852', alternate_script: false)
                                  .each_matching_line(rec) do |field, spec, extractor|
              holding = {}
              field.subfields.each do |sf|
                case sf.code
                when 'b'
                  holding['loc_b'] = sf.value.strip
                when 'c'
                  holding['loc_n'] = sf.value.strip
                when 'h'
                  holding['class_number'] = sf.value
                when 'i'
                  holding['cutter_number'] = sf.value
                when 'A'
                  holding['summary'] = sf.value
                when 'B'
                  holding['supplement'] = sf.value
                when 'C'
                  holding['index'] = sf.value
                when 'z'
                  holding['notes'] ||= []
                  holding['notes'] << sf.value
                # per Stewart Engart
                when 'x'
                  holding['availability'] = sf.value
                when 'E'
                  holding['notes'] ||= []
                  holding['notes'] << sf.value
                end
              end

              call_number = [holding.delete('class_number'),
                             holding.delete('cutter_number')].compact.join(' ')

              holding['call_no'] = call_number unless call_number.empty?

              summary = holdings_summary_with_labels(holding)

              holding['summary'] = summary unless summary.empty?

              # Add special_collections = true to clipboard to use
              # later to remove rollup_id for special collections items.
              if holding['loc_b'] =~ /^(SCL|ARCH)$/
                ctx.clipboard['special_collections'] = true
              end

              acc << holding.to_json if holding.any?
            end
          end
        end

        def holdings_summary_with_labels(holding)
          labels = ['Holdings',
                    'Indexes',
                    'Supplements']
          summaries = [holding.delete('summary'),
                       holding.delete('index'),
                       holding.delete('supplement')]
          labels.zip(summaries)
                .reject { |i| i[1].nil? }
                .map { |e| e.join(': ') }
                .join('; ')
        end

        ################################################
        # ItemStatus
        ######

        module ItemStatus
          def self.is_available?(items)
            items.any? { |i| i['status'].downcase.start_with?('available') rescue false }
          end

          # TODO! Aleph makes it challenging to determine item status.
          # This method duplicates the logic in aleph_to_endeca.pl
          # that determines item status.
          # Refactoring would help, but let's just get it working.
          def self.set_status(rec, item)
            status_code = item['status_code'].to_s
            process_state = item['process_state'].to_s
            due_date = item['due_date'].to_s
            item_id = item['item_id'].to_s
            location_code = item['location_code'].to_s
            type = item['type'].to_s
            call_no = item['call_no'].to_s

            if !due_date.empty? && process_state != 'IT'
              status = 'Checked Out'
            elsif !due_date.empty? && call_no.empty?
              status = 'On Order'
            elsif status_code == '00'
              status = 'Not Available'
            elsif status_code == 'P3'
              status = 'Ask at Reference Desk'
            elsif !process_state.empty?
              if process_state == 'NC'
                if newspaper?(rec) || periodical?(rec)
                  if status_code == '03' || status_code == '08' || status_code == '02'
                    status = 'Available - Library Use Only'
                  else
                    status = 'Available'
                  end
                elsif microform?(rec)
                  status = 'Ask at Circulation Desk'
                elsif item_id =~ /^B\d{6}/
                  status = 'Ask at Circulation Desk'
                elsif location_state_map[location_code] == 'C' || location_state_map[location_code] == 'B'
                  if status_code == '03' || status_code == '08' || status_code == '02'
                    status = 'Available - Library Use Only'
                  else
                    status = 'Available'
                  end
                elsif location_state_map[location_code] == 'N'
                  status = 'Not Available'
                else
                  if status_code == '03' || status_code == '08' || status_code == '02'
                    status = 'Available - Library Use Only'
                  else
                    status = 'Ask at Circulation Desk'
                  end
                end
              else
                if status_map[process_state]
                  status = status_map[process_state]
                else
                  status = 'UNKNOWN'
                end
              end
            elsif status_code == 'NI' || item_id =~ /^B\d{6}/
              if type == 'MAP' && status_code != 'NI'
                status = 'Available'
              elsif location_state_map[location_code] == 'A' || location_state_map[location_code] == 'B'
                if status_code == '03' || status_code == '08' || status_code == '02'
                  status = 'Available - Library Use Only'
                else
                  status = 'Available'
                end
              elsif location_state_map[location_code] == 'N'
                status = 'Not Available'
              else
                # NOTE! There's a whole set of additional elsif conditions in the Perl script,
                # the result of which seems to be to set the status to 'Ask at Circulation Desk'
                # no matter whether any condition is met.
                # It also sets %serieshash and $hasLocNote vars.
                # Skipping all that for now.
                # See line 5014 of aleph_to_endeca.pl
                status = 'Ask at Circulation Desk'
              end
            else
              if status_code == '03' || status_code == '08' || status_code == '02'
                status = 'Available - Library Use Only'
              else
                status = 'Available'
              end
            end

            if online?(rec) && status == 'Ask at Circulation Desk'
              status = 'Available'
              # NOTE! In the aleph_to_endeca.pl script (line 5082) there's some code
              #       about switching the location to PEI. But let's pretend
              #       that's not happening for now.
            end

            status
          end

          def self.status_map
            @status_map ||= Traject::TranslationMap.new('duke/process_state')
          end

          def self.location_state_map
            @location_state_map ||= Traject::TranslationMap.new('duke/location_default_state')
          end

          def self.select_fields(rec, field_tag)
            rec.fields.select { |f| f.tag == field_tag }
          end

          def self.select_indicator2(rec, field_tag)
            select_fields(rec, field_tag).map { |field| field.indicator2 }
          end

          def self.find_subfield(rec, field_tag, subfield_code)
            select_fields(rec, field_tag).map do |field|
              field.subfields.find do |sf|
                sf.code == subfield_code
              end
            end
          end

          def self.subfield_has_value?(rec, field_tag, subfield_code, subfield_value)
            find_subfield(rec, field_tag, subfield_code).any? do |subfield|
              subfield.value == subfield_value
            end
          end

          def self.indicator_2_has_value?(rec, field_tag, indicator_value)
            select_indicator2(rec, field_tag).any? do |indicator|
              indicator == indicator_value
            end
          end

          def self.newspaper?(rec)
            subfield_has_value?(rec, '942', 'a', 'NP') ||
            (rec.leader.byteslice(7) == 's' && rec['008'].value.byteslice(21) == 'n')
          end

          def self.periodical?(rec)
            subfield_has_value?(rec, '942', 'a', 'JR') ||
            (rec.leader.byteslice(7) == 's' && rec['008'].value.byteslice(21) == 'p')
          end

          def self.serial?(rec)
            rec.leader.byteslice(7) == 's' ||
            subfield_has_value?(rec, '852', 'D', 'y') ||
            subfield_has_value?(rec, '942', 'a', 'AS')
          end

          def self.microform?(rec)
            subfield_has_value?(rec, '942', 'b', 'Microform')
          end

          def self.online?(rec)
            indicator_2_has_value?(rec, '856', ' ') ||
            indicator_2_has_value?(rec, '856', '0') ||
            indicator_2_has_value?(rec, '856', '1')
          end
        end

        module LocationMap
          def self.location_hierarchy_map
            @location_hierarchy_map ||= Traject::TranslationMap.new('duke/location_hierarchy')
          end

          def self.map_locations_to_hierarchy(items)
            locations = ['duke']
            items.each do |item|
              loc_b = item.fetch('loc_b', nil)
              loc_n = item.fetch('loc_n', nil)
              locations << location_hierarchy_map[loc_b] if loc_b
              locations << location_hierarchy_map[loc_n] if loc_n
            end

            locations.map { |loc| loc.split('|') if loc }
                     .flatten
                     .map { |c| c.split(';') if c }
                     .compact
          end
        end


        ################################################
        # NormalizeCallNumber
        ######

        # Module with routine that tries to turn whatever happens
        # to be in the call number and copy number fields into
        # something that can be sorted.
        module NormalizeCallNumber
          def self.normalize_cn_and_copy_info(cn_and_copy_info)
            cn_and_copy_info_dup = cn_and_copy_info.dup
            cn_and_copy_info_dup.strip!
            cn_and_copy_info_dup.gsub!('\n','')
            cn_and_copy_info_dup.gsub!(/fully processed/i, '')

            # Plan A -- try to use Lcsort to normalize the string
            #           as an LC Call Number.
            #           This will return nil if no go.
            if lc = Lcsort.normalize(cn_and_copy_info_dup)
              return lc
            end

            # Plan B -- split the string on any non-alphanumeric chars
            #           also split the string between alpha and num
            cn_and_copy_info_dup.split(/[^0-9a-zA-Z]/)
                   .map { |i| i.scan(/\d+|\D+/) }
                   .flatten
                   .map do |c|
              # All digits? Terrific -- pad it out to 6 positions
              # so we can sort it like a string.
              if c =~ /\d+/
                c.rjust(6, '0')
              # If it's all alpha first try to see if it can be
              # parsed as a date. If so, OK, turn the date into
              # a two digit month.
              elsif date?(c)
                sprintf('%02d', Date.parse(c).month.to_i)
              # Upcase anything that's left and hope for the best.
              else
                c.upcase
              end
            end.compact.reject(&:empty?).join('.')
          end

          def self.date?(str)
            begin
               Date.parse(str)
            rescue ArgumentError
               false
            end
          end
        end
      end
    end
  end
end
