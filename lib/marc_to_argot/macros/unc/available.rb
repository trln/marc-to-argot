module MarcToArgot
  module Macros
    module UNC
      module Available

        def available(rec, cxt)
          out = cxt.output_hash
          item_statuses = get_statuses(out['items']) if out['items']
          out['available'] = 'Available' if is_available?(item_statuses)
        end

        private

        def is_available?(statuses)
          available_statuses = ['Ask the MRC', 'Available', 'Contact Library for Status', 'In-Library Use Only']
          statuses.any? { |s| available_statuses.include?(s) rescue false }
        end

        def get_statuses(items)
          to_j = items.map{ |e| JSON.parse(e) }
          statuses = to_j.map{ |e| e['status'] }
          return statuses.compact.uniq if statuses.length > 0
        end
      end
    end
  end
end 
