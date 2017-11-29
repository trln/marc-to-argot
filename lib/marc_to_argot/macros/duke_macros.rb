module MarcToArgot
  module Macros
    # Macros and useful functions for Duke records
    module Duke
      include MarcToArgot::Macros::Shared

      # Check for physical item record returns true unless it
      # has an 856 where the first indicator is 0.
      def physical_access?(rec, _ctx = {})
        l = rec.fields('856')
        return false if !l.find { |f| ['0'].include?(f.indicator2) }.nil?
        true
      end
    end
  end
end
