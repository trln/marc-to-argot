# coding: utf-8

module MarcToArgot
  module Macros
    module UNC
      module CallNumber
        include MarcToArgot::Util

        # extracts call numbers from items/bibs
        # and maps them into the output_hash
        # populates:
        #   `call_number_schemes`,
        #   `shelfkey`,
        #   `reverse_shelfkey`,
        #   `lcc_callnum_classification`
        # and populates call number searching fields:
        #   `lc_call_nos_normed` (LC)
        #   `shelf_numbers` (ALPHANUM)
        def process_call_numbers(rec, cxt)
          out = cxt.output_hash

          items = out['items']&.map { |i| JSON.parse(i) }
          call_numbers = extract_item_call_numbers(items)

          bib_call_numbers = extract_bib_call_numbers(rec)
          bib_call_numbers.each do |scheme, cns|
            next if cns.empty?

            if call_numbers.key?(scheme)
              call_numbers[scheme] += cns
            else
              call_numbers[scheme] = cns
            end
          end
          return if call_numbers.empty?

          call_numbers.each do |scheme, cns|
            cns.map! { |cn| LCC.normalize(cn) } if scheme == 'LC'
            cns.uniq!
            cns.delete('')
          end

          out['lc_call_nos_normed'] = call_numbers['LC'] if call_numbers['LC']
          out['shelf_numbers'] = call_numbers['ALPHANUM'] if call_numbers['ALPHANUM']

          cxt.output_hash['call_number_schemes'] = call_numbers.keys
          map_shelfkeys!(out, call_numbers)
          map_multi_callnum_classification(out, call_numbers)
        end

        private

        # Extracts call numbers from item data
        #
        # The call numbers are stripped but not normalized, uniq'd.
        # Returns an empty hash if no item call numbers.
        def extract_item_call_numbers(items)
          return {} unless items

          cns = {}
          items.each do |i|
            scheme = i['cn_scheme']
            next unless scheme

            numbers = (cns[scheme] ||= [])
            numbers << i['call_no'].strip
          end
          cns
        end

        # Extracts call numbers from bib fields
        #
        # The call numbers are stripped but not normalized, uniq'd.
        # Returns an empty hash if no bib call numbers.
        #
        # We do not extract DDC/NLM/NAL call numbers because they are not
        # yet used in searching/shelfkeys.
        def extract_bib_call_numbers(rec)
          call_numbers = {}
          Traject::MarcExtractor.cached('050:086:090', alternate_script: false).each_matching_line(rec) do |field, _spec, _extractor|
            scheme = case field.tag
                     when '050', '090'
                       'LC'
                     when '086'
                       'SUDOC'
                     end
            cutter = field['b'] if scheme == 'LC'
            cns = field.select { |sf| sf.code == 'a' }.map(&:value)
            numbers = (call_numbers[scheme] ||= [])
            cns.each do |cn|
              numbers << if cutter
                           "#{cn} #{cutter}".strip
                         else
                           cn.strip
                         end
            end
          end
          call_numbers
        end

        def map_multi_callnum_classification(out, call_numbers)
          return if !call_numbers.key?('LC') || call_numbers['LC'].nil? || call_numbers['LC'].empty?
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
