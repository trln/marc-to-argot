module MARC

  # Extending the Marc DataField class to add some helpers
  class DataField

    def subfields_with_code(code)
      subfields.select { |sf| sf.code == code }
    end

    def subfields_with_code?(code)
      !subfields_with_code(code).nil?
    end

    def subfield_with_value_of_code?(value, code)
      !subfields.find { |sf| sf.code == code && sf.value == value}.nil?
    end

    def subfield_values_from_code(code)
      subfields_with_code(code).map { |sf| sf.value }
    end

  end
end