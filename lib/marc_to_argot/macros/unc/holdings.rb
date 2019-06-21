module MarcToArgot
  module Macros
    module UNC
      module Holdings

        # There is one 999 92 per holdings record, with the basic info about that holdings record.
        #  a = holdings record number
        #  b = location code
        #  c = holdings card count

        # There are multiple 999 93 fields associated with each 999 92, linked by the holdings
        #  record number in the 999 92 $a and 999 93 $0.
        # Each 999 93 represents one variable field from the holdings record specified.
        #  0 = holdings record number
        #  2 = MARC field tag for variable field
        #  3 = III field group tag for variable field
        #  other subfields -- the actual subfield code in the data

        # Initial logic for processing these fields is specified in holdings_data_logic.org.
        # The main idea is:
        # - 852 field with III tag = c is extracted.
        # - 86[345678] fields with III tag = h are extracted.
        # -- According to Kurt Blythe, if these fields are coded otherwise (usually g for
        #    DRA Holdings), they should NOT display to the public.

        def holdings(rec, cxt)
          unless cxt.clipboard[:shared_record_set] == 'dws'
            # create HoldingsRecord objects to process
            tmp_holdings = create_temp_holdings_for_processing(rec)
            if tmp_holdings && tmp_holdings.length > 0
              # process them to extract the necessary data
              tmp_holdings.each { |hrec| hrec.process_holdings_data }
              # write them out to argot
              argotholdings = []
              tmp_holdings.each { |hrec| argotholdings << hrec.to_argot }
              cxt.output_hash['holdings'] = argotholdings if argotholdings.length > 0
            end
          end
        end

        # creates HoldingsRecords with relevant fields for display and processing
        # after doing this, we can process the fields without having to check III
        #  field type constantly
        def create_temp_holdings_for_processing(rec)
          # init_holdings is a hash of the parameters needed to create a
          #  HoldingsRecord object.
          # Initially we set the first 4, which come from 999 92s
          init_holdings = {}
          occ = 0
          Traject::MarcExtractor.cached("999|92|").each_matching_line(rec) do |field, spec, extractor|
            id = field['a']
            loc = field['b']
            next if loc.start_with?('e')
            ct = field['c']
            occ = occ += 1

            init_holdings[id] = [id, loc, ct, occ]
          end

          if init_holdings.length > 0
          # field_hash
          #  key = holdings record id
          #  value = array of MARC::DataFields created from 999 93s determined to
          #    be relevant to subsequent display/processing
          field_hash = {}
          
          Traject::MarcExtractor.cached("999|93|").each_matching_line(rec) do |field, spec, extractor|
            recid = field['0']

            df = new_data_field(field) if 
              ( field['2'] == '852' && field['3'] == 'c' ) ||
              ( field['2'] =~ /85[345]/ && field['3'] == 'y' ) ||
              ( field['2'] =~ /86./ && field['3'] == 'h' )

            if df
              if field_hash.has_key?(recid)
                field_hash[recid] << df
              else
                field_hash[recid] = [df]
              end
            end
          end

          # field_hash values are appended to the relevant parameter array of init_holdings
          field_hash.each { |k, v| init_holdings[k] << v }

          # create new HoldingsRecord object 
          holdings_array = []
          init_holdings.each_value do |hdata|
            # if there are no relevant variable fields, we don't need to output holdings data
            if hdata.size == 5
              holdings_array << HoldingsRecord.new(hdata[0], hdata[1], hdata[2],
                                                   hdata[3], hdata[4]) 
            end
          end

          # make sure they are in ILS order
          return holdings_array.sort_by { |h| h.occ }
          end
        end


        # helper to turn nasty 999 93 fields from the bib into proper MARC::DataFields
        #  following the MARC holdings format -- just easier to work with
        def new_data_field(field)
          datafield = MARC::DataField.new(field['2'],
                                          field.indicator1,
                                          field.indicator2)
          field.subfields.each do |sf|
            unless %w[0 2 3].include?(sf.code)
              datafield.append(MARC::Subfield.new(sf.code, sf.value))
            end
          end
          datafield
#          puts "DATAFIELD: #{datafield.inspect}"
        end

        class HoldingsRecord
          attr_reader :id
          attr_reader :loc
          attr_reader :card_ct
          attr_reader :fields
          attr_reader :occ
          attr_accessor :call_numbers
          attr_accessor :notes
          attr_accessor :summary_holding
          attr_accessor :summary_holding_supplement
          attr_accessor :summary_holding_index

          # create the HoldingsRecord object with initial read-only attributes
          #  and the other attributes set up to push to
          # @fields.freeze out of paranoia that extract_notes or extract_textual_summary_holdings
          #  was messing with the contents. Not entirely sure it does anything.
          def initialize(id, loc, ct, occ, fields)
            @id = id
            @loc = loc
            @card_ct = ct
            @occ = occ
            @fields = fields.freeze
            @call_numbers = []
            @notes = []
            @patterns = {}
            @enums_and_chrons = {}
            @summary_holding = []
            @summary_holding_supplement = []
            @summary_holding_index = []
          end

          # do the heavy lifting
          def process_holdings_data
            extract_call_numbers
            extract_notes
            extract_textual_summary_holdings
            build_summary_holdings if @summary_holding.empty?
          end

          def get_852s
            @fields.select { |f| f.tag == '852' }
          end

          def get_textual_holdings_fields
            @fields.select { |f| ['866', '867', '868'].include?(f.tag) }
          end

          def extract_call_numbers
            get_852s.each do |f|
              cn_sf_vals = f.select { |sf| %w[h i j k].include?(sf.code) }.map { |sf| sf.value }
              @call_numbers << cn_sf_vals.join(' ') unless cn_sf_vals.empty?
            end
          end

          def extract_notes
            note_fields = get_852s + get_textual_holdings_fields
            note_fields.each do |f|
              n_sf_vals = f.select { |sf| sf.code == 'z'}.map { |sf| sf.value }
              n_sf_vals.each { |n| @notes << n } unless n_sf_vals.empty?
            end
          end

          def extract_textual_summary_holdings
            sh_fields = get_textual_holdings_fields
            sh_fields.each do |f|
              # A single field may have multiple $a values which should be joined with ', '
              summary = f.select { |sf| sf.code == 'a'}.map { |sf| sf.value }.join(', ')
              # Push the string from this field to the appropriate attribute array, where
              #   we are collecting holdings summaries from different fields
              unless summary.empty?
                case get_field_type(f)
                when :basic
                  @summary_holding << summary
                when :supp
                  @summary_holding_supplement << summary
                when :index
                  @summary_holding_index << summary
                end
              end
            end

            # I don't like this next part being here but it's working-ish right now
            # Summary holdings statements of the same type from different variable fields
            #   get joined with '; '
            @summary_holding = @summary_holding.join('; ').strip
            @summary_holding_supplement = @summary_holding_supplement.join('; ').strip
            @summary_holding_index = @summary_holding_index.join('; ').strip
          end

          # if there are no textual summary holdings, we need to build them.
          # the horror... the horror...
          def build_summary_holdings
            get_patterns
#            puts "PATTERNS: #{@patterns}"
            get_enums_and_chrons
#            puts "ENUMS & CHRONS: #{@enums_and_chrons}"
            apply_patterns unless @patterns.empty? || @enums_and_chrons.empty?
#            puts "BSH: #{@summary_holding}"
          end

          def apply_patterns
            p = @patterns
            ec = @enums_and_chrons

            p.each do |holding_type, patterns|
              result = []
              patterns.each do |pid, pattern|
#                puts "PATTERN: #{pattern}"
                result << process_pattern(holding_type, pid, pattern)
              end
              
              case holding_type
              when :basic
                @summary_holding = result.join('; ')
              when :supp
                @summary_holding_supplement = result.join('; ')
              when :index
                @summary_holding_index = result.join('; ')
              end
            end
          end

          def process_pattern(holding_type, pid, pattern)
#            puts "\n\nPATTERN: #{pattern.inspect}"
            summary = []
            psfs = pattern.keys
            
            get_ecs_data_matching_pattern(holding_type, pid).each do |ec|
#              puts "EC: #{ec.inspect}"
              numeration = { :open => [], :close => [] }
              alt_numeration = { :open => [], :close => [] }
              chron_pieces = { :open => { :year  => '',
                                          :month => '',
                                          :day => '',
                                          :other => ''
                                        },
                               :close => { :year  => '',
                                          :month => '',
                                          :day => '',
                                          :other => ''
                                         }
                             }
              pub_note = []

              pub_note << ec[:sfs]['z'] if ec[:sfs].has_key?('z')
#              puts "PUB NOTE: #{pub_note}"
                              
              sfs = ec[:sfs].keys.sort
              sfs.delete('z')
#              puts "SFS: #{sfs}"
              sfs.each do |sf|
                if psfs.include?(sf)
#                  puts ec[:sfs][sf]
#                  puts ec[:sfs][sf][:open]
                  ov = process_pattern_subfield(pattern, sf, ec[:sfs][sf][:open])
                  cv = process_pattern_subfield(pattern, sf, ec[:sfs][sf][:close]) if ec[:rangeness]

                  ov = '' if ov.nil?
                  cv = '' if cv.nil?
                  
                  chron_type = :other if 'ijkl'.include?(sf)
                  case get_pattern_segment_value(pattern, sf).downcase
                  when /year/
                    chron_type = :year
                  when /month/
                    chron_type = :month
                  when /season/
                    chron_type = :month
                  when /day/
                    chron_type = :day
                  end

                  case sf
                  when /[abcdef]/
                    if chron_type
                      chron_pieces[:open][chron_type] << ov
                      chron_pieces[:close][chron_type] << cv if ec[:rangeness]
                    else
                      numeration[:open] << ov
                      numeration[:close] << cv if ec[:rangeness]
                    end
                  when /[gh]/
                    alt_numeration[:open] << ov
                    alt_numeration[:close] << cv if ec[:rangeness]
                  when /[ijk]/
                    chron_pieces[:open][chron_type] << ov
                    chron_pieces[:close][chron_type] << cv if ec[:rangeness]
                  when 'l'
                    chron_pieces[:open][:other] << ov
                    chron_pieces[:close][:other] << cv if ec[:rangeness]
                  end
                 end
               end
              numeration = numeration.map{ |k, v| [k, v.join(':')] }.to_h
              
#              puts chronology elements in the right order for display
              chron_pieces.each do |range_type, pieces|
                result = []
                result << "#{translate_month(pieces[:month])} " if pieces[:month].length > 0
                result << "#{pieces[:day]}, " if pieces[:day].length > 0
                result << pieces[:year] if pieces[:year]
                result << pieces[:other] if pieces[:other]
                chron_pieces[range_type][:compiled] = result.join('')
              end
                
              result = ''
#              puts "NUMOPEN: #{numeration[:open].inspect}"
#              puts "CHRONOPEN: #{chron_pieces[:open][:compiled].inspect}"

              if numeration[:open].length > 0 && chron_pieces[:open][:compiled].length > 0
                result << "#{numeration[:open]} (#{chron_pieces[:open][:compiled]})"
              elsif numeration[:open].length > 0 && chron_pieces[:open][:compiled].empty?
                result << "#{numeration[:open]}"
              elsif numeration[:open].empty? && chron_pieces[:open][:compiled].length > 0
                result << chron_pieces[:open][:compiled]
              end

#              puts "NUMCLOSE: #{numeration[:close].inspect}"
#              puts "CHRONCLOSE: #{chron_pieces[:close][:compiled].inspect}"
              if numeration[:close].length > 0 && chron_pieces[:close][:compiled].length > 0
                result << " - "
                result << "#{numeration[:close]} (#{chron_pieces[:close][:compiled]})"
              elsif numeration[:close].length > 0 && chron_pieces[:close][:compiled].empty?
                result << " - "
                result << "#{numeration[:close]}"
              elsif numeration[:close].empty? && chron_pieces[:close][:compiled].length > 0
                result << " - "
                result << chron_pieces[:close][:compiled]
              end

              alt_numeration = alt_numeration.map{ |k, v| [k, v.join(':')] }.to_h
              result << " = #{alt_numeration[:open]}" if alt_numeration[:open].length > 0
              result << " - #{alt_numeration[:close]}" if alt_numeration[:close].length > 0
              
              result << " #{pub_note.join(' ')}" unless pub_note.empty?
#              puts "RESULT: #{result}"
              summary << result
             end
               return summary.reject{ |e| e == '' }.join(', ')
          end

          def translate_month(month)
            month = '0' + month if month.match?(/^\d$/)
            if holdings_month[month]
              holdings_month[month]
            else
              month
            end
          end
            
          def holdings_month
            @holdings_month ||=Traject::TranslationMap.new('unc/holdings_months')
          end

          def get_pattern_segment_value(pattern, sfcode)
            pattern[sfcode][:value]
          end

          def process_pattern_subfield(pattern, sfcode, sfval)
            label = "#{pattern[sfcode][:value]}" if pattern[sfcode][:is_label]
            if sfval.nil? || sfval.empty?
              return ''
            else
              if label
                value = "#{label}#{sfval}"
#               puts "SFVAL: #{value}"
                return value
              else
#               puts "SFVAL: #{value}"
                return sfval
              end
            end
          end
          
          # returns array of enum/chron field data, sorted by occurrence
          def get_ecs_data_matching_pattern(type, pid)
            result_hash = @enums_and_chrons[type][pid]
            results = []
            if result_hash
              result_hash.keys.sort.each { |occnum| results << result_hash[occnum] }
            end
            return results
          end
          
          # return hash of data from the enumeration and chronology fields
          # { :basic => {
          #     '1' => {            #this is the pattern id
          #       '1' => {          #this is the enum/chron occurrence
          #         'a' => {:open => '1', :close => '27'},
          #         'b' => {:open => '1', :close => '4'},
          #         'i' => {:open => '1900', :close => '1927'},
          #         'j' => {:open => 'Jan', :close => 'Jun'}
          #     }
          #    }
          #   },
          #   :supp => {...},
          #   :index => {...}
          # }
          def get_enums_and_chrons
            ecfs = @fields.select{ |f| f.tag =~ /86[345]/ }
            unless ecfs.empty?
              enums_and_chrons = {:basic => {},
                                  :supp => {},
                                  :index => {}
                                 }
              
              ecfs.each do |ecf|
                pid = get_pattern_id(ecf)
                po = get_pattern_occurrence(ecf)
                enum_chron = { :sfs => {} }
                type = get_field_type(ecf)
                has_ranges = includes_range_data(ecf)
                enum_chron[:rangeness] = true if has_ranges == true
                
                ecf.subfields.each do |sf|
                  if sf.code == '8'
                    next
                  elsif sf.code == 'z'
                    enum_chron[:sfs][sf.code] = sf.value
                  else
                    if has_ranges == true
                      enum_chron[:sfs][sf.code] = split_enum_chron_range_data(sf.value)
                    else
                      enum_chron[:sfs][sf.code] = split_enum_chron_nonrange_data(sf.value)
                    end
                  end
                end
                if enums_and_chrons[type].has_key?(pid)
                  enums_and_chrons[type][pid].merge!({ po => enum_chron })
                else
                  enums_and_chrons[type][pid] = { po => enum_chron }
                end
              end
              @enums_and_chrons = enums_and_chrons
#             puts @enums_and_chrons
            end
          end

          def includes_range_data(field)
            check_sfs = field.subfields.select{ |sf| sf.code.match?(/[abcdefijkl]/) }
            range_sfs = check_sfs.reject{ |sf| sf.value.match?(/- *$/) || !sf.value.include?('-') }
            return true unless range_sfs.empty?
          end

          def split_enum_chron_range_data(string)
            if string =~ /^ ?-/
              arr = string.split('-')
              open = nil
              close = arr[1]
            else
              arr = string.split(/ ?- ?/)
              open = arr[0]
              if arr[1]
                close = arr[1]
              else
                close = arr[0]
              end
            end
            {:open => open, :close => close}
          end

          def split_enum_chron_nonrange_data(string)
            {:open => string.delete('-')}
          end

          # return hash of caption and chronology patterns
          # { :basic => {
          #     '1' => {
          #       'a' => {:value => 'v.', :is_label => true},
          #       'b' => {:value => 'no.', :is_label => true},
          #       'i' => {:value => 'year', :is_label => nil},
          #       'j' => {:value => 'month', :is_label => nil}
          #     }
          #   },
          #   :supp => {...},
          #   :index => {...}
          # }
          def get_patterns
            pfs = @fields.select{ |f| f.tag =~ /85[345]/ }
            unless pfs.empty?
            patterns = {:basic => {},
                        :supp => {},
                        :index => {}
                       }
            
              
            pfs.each do |pf|
#              puts "PATTERN FIELD: #{pf.inspect}"
              pid = get_pattern_id(pf)
              pattern = {}
              type = get_field_type(pf)
              
              pf.subfields.each do |sf|
                if sf.code == '8'
                  next
                else
#                  puts "SF VALUE: #{sf.value.inspect}"
                  pattern[sf.code] = get_pattern_segment(sf.value)
                end
              end

              patterns[type][pid] = pattern
            end
            @patterns = patterns
#            puts "PATTERNS: #{@patterns}"
            end
          end

          def get_pattern_segment(string)
#            puts "STRING: #{string.inspect}"
            is_label = true unless string =~ /\(.*\)/
            cleaned = string.gsub(').', ')').delete('()')
            {:value => cleaned, :is_label => is_label}
          end

          def get_pattern_id(field)
            sf8 = field.subfields.select{ |sf| sf.code == '8'}.first
            if sf8
              sf8.value.split('.')[0]
            else
              'na'
            end
          end

          def get_pattern_occurrence(field)
            sf8 = field.subfields.select{ |sf| sf.code == '8'}.first
            if sf8
              sf8.value.split('.')[1].to_i
            else
              'na'
            end
          end

          def get_field_type(field)
            case field.tag
            when /8[56]3|866/
              :basic
            when /8[56]4|867/
              :supp
            when /8[56]5|868/
              :index
            end
          end

          # translate the HoldingsRecord object into Argot format
          def to_argot
            argot_holding = {}
            argot_holding['holdings_id'] = @id if @card_ct.to_i > 0
            argot_holding['loc_b'] = @loc
            argot_holding['loc_n'] = @loc
            argot_holding['call_no'] = @call_numbers.join('; ') unless @call_numbers.empty?
            argot_holding['notes'] = @notes.uniq unless @notes.empty?

            # gather the 3 types of summary_holdings, add the appropriate labels, and
            #  join them all with '; '
            summary = []
            summary << @summary_holding unless @summary_holding.empty?
            if @summary_holding_supplement.length > 0
              summary << 'Supplements: ' + @summary_holding_supplement
            end
            if @summary_holding_index.length > 0
              summary << 'Indexes: ' + @summary_holding_index
            end
            argot_holding['summary'] = summary.join('; ') unless summary.empty?
            
            argot_holding.to_json
          end
        end

      end
    end
  end
end
