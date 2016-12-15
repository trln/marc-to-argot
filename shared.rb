to_field "id", extract_marc("001", :first => true) do |marc_record, accumulator, context|
  accumulator.collect! {|s| "#{s}"}
end

to_field "source", literal("TRLN")