require 'set'

module MarcToArgot
  module Macros
    # Shared macros for TRLN institutions.  Default implementations are
    # defined here, and overriden in institution-specific modules in the
    # same namespace.
    module Shared
      # values to look for in the 856 that indicate
      # a record has online access.
      ELOC_IND2 = Set.new(%w[0 1])

      # tests whether the record has an 856[ind2] that matches
      # any of the values in ELOC_IND2
      # @param rec [MARC::Record] the record to be checked.
      # @param _ctx [Object] extra context or data to be used in the test
      #   (for overrides)
      def online_access?(rec, _ctx = {})
        l = rec.fields('856')
        return false if l.nil?
        !l.find { |f| ELOC_IND2.include?(f.indicator2) }.nil?
      end

      # tests whether the record has any physical items
      # this implementation asks whether there are any 999 fields.
      # @param rec [MARC::Record] the record to be checked.
      # @param _ctx [Object] extra context or data to be used in the test
      #   (for overrides)
      def physical_access?(rec, _ctx = {})
        !rec['999'].nil?
      end
    end
  end
end
