module MarcToArgot
  module Macros
    module NCSU
      # Utilities for working with NCSU item records
      module ItemUtils
        def self.sort_items(items)
          items.map { |i| SortableItem.new(i) }.sort.map(&:to_h)
        rescue ArgumentError
          warn("Unable to process #{items}")
          items
        end
        # Dirty hack to allow sorting items in a way
        # Symphony will not let us
        class SortableItem
          def initialize(hash)
            @_h = hash
          end

          def library
            @_h['loc_b']
          end

          def location
            @_h['loc_n']
          end

          def callnum
            @_h['call_no']
          end

          def scheme
            @_h['cn_scheme']
          end

          def to_h
            @_h
          end

          def lc_callnum?
            @_h['cn_scheme'] == 'LC'
          end

          def lcpad
            @lcpad ||= Lcsort.normalize(@_h['call_no']) if lc_callnum?
          end

          def <=>(other)
            libcomp = library <=> other.library
            return libcomp unless libcomp.zero?

            loccomp = location <=> other.location
            return loccomp unless loccomp.zero?

            return -1 if lc_callnum? && !other.lc_callnum?

            return 1 if other.lc_callnum? && !lc_callnum?

            return lcpad <=> other.lcpad if lcpad && other.lcpad

            callnum <=> other.callnum || 0
          end
        end
      end
    end
  end
end
