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
            # process them to extract the necessary data
            tmp_holdings.each { |hrec| hrec.process_holdings_data }
            # write them out to argot
            argotholdings = []
            tmp_holdings.each { |hrec| argotholdings << hrec.to_argot }
            cxt.output_hash['holdings'] = argotholdings
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
            ct = field['c']
            occ = occ += 1

            init_holdings[id] = [id, loc, ct, occ]
          end

          # field_hash
          #  key = holdings record id
          #  value = array of MARC::DataFields created from 999 93s determined to
          #    be relevant to subsequent display/processing
          field_hash = {}
          
          Traject::MarcExtractor.cached("999|93|").each_matching_line(rec) do |field, spec, extractor|
            recid = field['0']

            df = new_data_field(field) if 
              ( field['2'] == '852' && field['3'] == 'c' ) ||
              field['3'] == 'h'

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
          holdings_array.sort_by { |h| h.occ }
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
            @summary_holding = []
            @summary_holding_supplement = []
            @summary_holding_index = []
          end

          # do the heavy lifting
          #################################
          # THIS IS WHAT I CAN'T FIGURE OUT
          #################################          
          # Tests pass as long as extract_textual_summary_holdings is FIRST
          # Moving extract_call_numbers or extract_notes above extract_textual_summary_holdings
          #  breaks the 4 tests related to summary holdings
          def process_holdings_data
            extract_textual_summary_holdings
            extract_call_numbers
            extract_notes
          end

          def get_852s
            @fields.select { |f| f.tag = '852' }
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
                case f.tag
                when '866'
                  @summary_holding << summary
                when '867'
                  @summary_holding_supplement << summary
                when '868'
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
              summary << 'Supplementary holdings: ' + @summary_holding_supplement
            end
            if @summary_holding_index.length > 0
              summary << 'Index holdings: ' + @summary_holding_index
            end
            argot_holding['summary'] = summary.join('; ') unless summary.empty?
            
            argot_holding.to_json
          end
        end

      end
    end
  end
end
