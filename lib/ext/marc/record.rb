module MARC

  # Extending the Marc Record class to add some helpers
  class Record

    def uses_book_configuration_in_008?
      if leader.byteslice(6) =~ /[a]/ && leader.byteslice(7) =~ /[acdm]/
        true
      elsif leader.byteslice(6) == 't'
        true
      else
        false
      end
    end

  end
end
