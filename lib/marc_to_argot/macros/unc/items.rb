module MarcToArgot
  module Macros
    module UNC
      module Items

        def items(rec, cxt)
            items = []
            Traject::MarcExtractor.cached('999|*1|cdilnpqsv', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
              items << assemble_item(field)
            end

            #set barcodes field
            barcodes = items.map { |i| i['barcode'] }.compact
            cxt.output_hash['barcodes'] = barcodes if barcodes.length > 0

            items = items.map { |i| i.delete('barcode'); i.to_json }
            
            cxt.output_hash['items'] = items if items.length > 0
       end

        def assemble_item(field)
          item = { 'notes' => [] }
          call_no_tag = ''
          call_no_i1 = ''
          call_no_i2 = ''
          call_no_val = ''

          # https://github.com/trln/extract_marcxml_for_argot_unc/blob/master/attached_record_data_mapping.csv
          field.subfields.each do |subfield|
            
            sf = subfield.code
            subfield.value.gsub!(/\|./, ' ') #remove subfield delimiters and
            subfield.value.strip! #delete leading/trailing spaces
            case sf
            when 'b'
              item['barcode'] = subfield.value
            when 'c'
              item['copy_no'] = 'c. ' + subfield.value if subfield.value != '1'
            when 'd'
              item['due_date'] = subfield.value
            when 'i'
              item['item_id'] = subfield.value
            when 'l'
              item['loc_b'] = subfield.value
              item['loc_n'] = subfield.value
            when 'n'
                item['notes'] << subfield.value
            when 'p'
              call_no_tag = subfield.value[0, 3]
              call_no_i1 = subfield.value[3]
              call_no_i2 = subfield.value[4]
            when 'q'
              call_no_val = subfield.value
            when 's'
                item['status'] = status_map[subfield.value]
            when 'v'
              item['vol'] = subfield.value
            end
          end

          item['status'] = 'Checked Out' if item['due_date']

          if call_no_val.downcase.start_with?('shelved')
            item['notes'] << call_no_val
            call_no_val = ''
          else
            item['call_no'] = call_no_val
          end

          if item.has_key?('call_no')
            item['cn_scheme'] = set_cn_scheme(call_no_tag, call_no_i1, call_no_i2)            
          end

          item.delete('notes') if item['notes'].length == 0
          
          item
        end
        
        def status_map
          @status_map ||=Traject::TranslationMap.new('unc/status_map')
        end

        def set_cn_scheme(marc_tag, i1, i2)
          case marc_tag
          when '050'
            'LC'
          when '060'
            'NLM'
          when '070'
            'NAL'
          when '082'
            'DDC'
          when '083'
            'DDC'
          when '086'
            if i1 == '0'
              'SUDOC'
            else
              'ALPHANUM'
            end
          when '090'
            'LC'
          when '092'
            'DDC'
          when '096'
            'NLM'
          when '099'
            'ALPHANUM'
          else
            'ALPHANUM'
          end
        end

      end
    end
  end
end
