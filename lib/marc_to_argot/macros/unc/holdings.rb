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
            cxt.output_hash['holdings'] = create_holdings_for_processing(rec)
          end
        end

        def create_holdings_for_processing(rec)
          holdings = {}
          Traject::MarcExtractor.cached("999|92|").each_matching_line(rec) do |field, spec, extractor|
            id = field['a']
            loc = field['b']
            ct = field['c']
            holdings[id] = HoldingsRecord.new(id, loc, ct)
          end

          Traject::MarcExtractor.cached("999|93|").each_matching_line(rec) do |field, spec, extractor|
            recid = field['0']
            if field['2'] == '852' && field['3'] == 'c'
              holdings[recid].fields << field.to_s
            end
          end

          ha = []
          holdings.each_pair { |k, v| ha << "#{k} -- #{v.fields[0]}" }
          ha
        end

        def extract_call_number(field)
          subfield_z = field.find_all {|subfield| subfield.code == 'z'}
          call_number = field.find_all { |sf| %w[hijk
          hijk
        end

        #   # get array of holdings fields relevant to this processing/display
        #   holdings_fields = []
        #   Traject::MarcExtractor.cached("999|92|:999|93|").each_matching_line(rec) do |field, spec, extractor|
        #     holdings_fields << field if field.indicator2 == '2' ||
        #                                 (field.indicator2 == '3' && (field.tag == '852' ||
        #                                                              field['3'] == 'h')
        #                                 )
            
        #   end

          
        # end

        class HoldingsRecord
          attr :id
          attr :loc
          attr :card_ct
          attr :fields

          def initialize(id, loc, ct)
            @id = id
            @loc = loc
            @card_ct = ct
            @fields = []
          end
        end

        class HoldingsField < MARC::DataField
        end

      end
    end
  end
end
