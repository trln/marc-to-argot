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


        end
        
        def map_call_numbers!(ctx, items)
          call_numbers = extract_call_numbers(items)
          out = ctx.output_hash
          ctx.output_hash['call_number_schemes'] = call_numbers.keys
          map_shelfkeys!(out, call_numbers)
          map_callnum_classification!(out, call_numbers)
        end

        def map_shelfkeys!(output_hash, call_numbers)
          %w[LC SUDOC].each do |scheme|
            numbers = call_numbers.fetch(scheme, [])
            key = numbers.first
            next unless key
            output_hash['shelfkey'] = "#{scheme.downcase}:#{key}"
            output_hash['reverse_shelfkey'] = "#{scheme.downcase}:#{ShelfKeys.reverse_shelfkey(key)}"
            break
          end
        end

        private

        def map_callnum_classification!(out, call_numbers)
          return unless call_numbers.key?('LC')
          raise ValueError, "#{call_numbers} has no LC call numbers" unless call_numbers['LC'].first
          res = []
          LCC.find_path(call_numbers['LC'].first).each_with_object([]) do |part, acc|
            acc << part
            res << acc.join('|')
          end
          out['lcc_callnum_classification'] = res
        end

        def extract_call_numbers(items)
          items.each_with_object({}) do |i, cns|
            scheme = i['cn_scheme']
            next unless %w[LC SUDOC].include?(scheme)
            numbers = (cns[scheme] ||= [])
            numbers << if scheme == 'LC'
                         LCC.normalize(i['call_no'])
                       else
                         i['call_no']
                       end
          end
        end
      end
    end
  end
end
