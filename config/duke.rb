to_field "id", extract_marc("001", :first => true) do |marc_record, accumulator, context|
  accumulator.collect! {|s| "DUKE#{s}"}
end

to_field "source", literal("DUKE")

to_field "holdings_note", extract_marc("852:866")
