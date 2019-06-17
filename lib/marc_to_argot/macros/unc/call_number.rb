# coding: utf-8

module MarcToArgot
  module Macros
    module UNC
      module CallNumber
        include MarcToArgot::Util

        # extracts call numbers from an items
        # and maps them into the output_hash
        # populates:
        #   `call_number_schemes`,
        #   `shelfkey`,
        #   `reverse_shelfkey`,
        #   `lcc_callnum_classification`

        def process_call_numbers(rec, cxt)
          out = cxt.output_hash
          if out['items']
            items = out['items'].map{ |i| JSON.parse(i) }
            item_call_numbers = extract_call_numbers(items)
          end
          
          bib_call_numbers = extract_bib_LC_call_numbers(rec)


          unless bib_call_numbers['LC'].empty?
            if item_call_numbers.nil?
              item_call_numbers = { 'LC' => bib_call_numbers['LC'] }
            elsif item_call_numbers.has_key?('LC')
              bib_call_numbers['LC'].each { |cn| item_call_numbers['LC'] << cn }
              item_call_numbers['LC'].uniq!
            else
              item_call_numbers['LC'] = bib_call_numbers['LC']
            end
          end

          if item_call_numbers
            cxt.output_hash['call_number_schemes'] = item_call_numbers.keys
            map_shelfkeys!(out, item_call_numbers)
            map_multi_callnum_classification(out, item_call_numbers)
          end

        end
        
        private

        def extract_bib_LC_call_numbers(rec)
          lc_call_numbers = []
          Traject::MarcExtractor.cached('050:090', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
            cutter = field['b']
            cns = field.select{ |sf| sf.code == 'a' }.map{ |sf| sf.value }
            next if cns.length == 0
            cns.each do |cn|
              if cutter
                lc_call_numbers << "#{cn} #{cutter}"
              else
                lc_call_numbers << cn
              end
            end
          end
          return { 'LC' => lc_call_numbers.map{ |cn| LCC.normalize(cn) }.uniq }
        end

        def map_multi_callnum_classification(out, call_numbers)
          return unless call_numbers.key?('LC')
          raise ValueError, "#{call_numbers} has no LC call numbers" unless call_numbers['LC']
          res = []
          call_numbers['LC'].each do |callnum|
            LCC.find_path(callnum).each_with_object([]) do |part, acc|
              acc << part
              res << acc.join('|')
            end
          end
          out['lcc_callnum_classification'] = res
        end

      end
    end
  end
end

