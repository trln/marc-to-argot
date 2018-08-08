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
        # - Any 852 field is extracted.
        # - 86[345678] fields with III tag = h are extracted.
        # -- According to Kurt Blythe, if these fields are coded otherwise (usually g for
        #    DRA Holdings), they should NOT display to the public.

        def holdings(rec, cxt)
          unless cxt.clipboard[:shared_record_set] == 'dws'
            holdings = create_holdings_for_processing(rec)
            holdings.each { |hrec| process_holdings_data(hrec) }
            
            cxt.output_hash['holdings'] = 
          end
        end

        # creates HoldingsRecords with relevant fields for display and processing
        # after doing this, we can process the fields without having to check III
        #  field type constantly
        def create_holdings_for_processing(rec)
          holdings = {}
          occ = 0
          Traject::MarcExtractor.cached("999|92|").each_matching_line(rec) do |field, spec, extractor|
            id = field['a']
            loc = field['b']
            ct = field['c']
            occ = occ += 1

            holdings[id] = HoldingsRecord.new(id, loc, ct, occ)
          end

          Traject::MarcExtractor.cached("999|93|").each_matching_line(rec) do |field, spec, extractor|
            recid = field['0']
              holdings[recid].fields << new_data_field(field)
if field['2'] == '852' && field['3'] == 'c'
            elsif field['3'] == 'h'
              holdings[recid].fields << new_data_field(field)
            end
          end
        end

        def new_data_field(field)
          datafield = MARC::DataField.new(field['2'],
                                          field.indicator1,
                                          field.indicator2)
          field.subfields.each do |sf|
            unless %w[0 2 3].include?(sf.code)
              datafield << [sf.code, sf.value]
            end
          end
        end

        def process_holdings_data(hrec)
        end

        class HoldingsRecord
          attr_reader :id
          attr_reader :loc
          attr_reader :card_ct
          attr_accessor :call_numbers
          attr_accessor :fields
          attr_reader :occ

          def initialize(id, loc, ct, occ)
            @id = id
            @loc = loc
            @card_ct = ct
            @call_numbers = []
            @fields = []
            @occ = occ
          end

          def self.extract_call_numbers
            cn_fields = @fields.find_all { |f| 
            call_number_elements = field.find_all { |sf| %w[h i j k].include?(sf.code) }
            return call_number_elements.join(' ') if !call_number_elements.empty?
          end



        end

        class HoldingsField < MARC::DataField
        end

      end
    end
  end
end
