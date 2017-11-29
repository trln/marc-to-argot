module MarcToArgot
  module Macros
    # Macros and useful functions for UNC records
    module Duke
      # expansive interpretation; 856ind2 blank, 0, or 1
      # see documentation of this constant in Shared module
      ELOC_IND2 = ['', '0', '1'].freeze
      include MarcToArgot::Macros::Shared

      # tests whether there are any physical items
      # attached to the record
      def physical_access?(rec, _ctx = {})
        !rec['940'].nil?
      end
    end
  end
end
