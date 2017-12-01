module MarcToArgot
  module Macros
    # Macros and useful functions for UNC records
    module UNC
      include MarcToArgot::Macros::Shared
      
      # tests whether the record has any physical items
      # this implementation asks whether there are any 999 fields that:
      #  - have i1=9 (in all records, dates are output to 999 w/i1=0), and
      #  - have i2<3 (i.e. an unsuppressed item or holding record exists)
      # Records with ONLY an order record will NOT be assigned an
      #  access_type value, given that it is presumed the item is on order
      #  and not at all accessible yet.
      # @param rec [MARC::Record] the record to be checked.
      # @param _ctx [Object] extra context or data to be used in the test
      #   (for overrides)
      def physical_access?(rec, _ctx = {})
        checkfields = []
        rec.each_by_tag('999') { |f| checkfields << f if f.indicator1 == '9' && f.indicator2.to_i < 3}
        if checkfields.size > 0
          return true
        else
          return false
        end
      end
    end
  end
end
