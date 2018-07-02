module MARC

  # Extending the Marc ControlField class to add some helpers
  class ControlField

    def uses_book_configuration_in_006?
      true if value.byteslice(0) =~ /[at]/
    end

  end
end
