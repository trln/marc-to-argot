settings do
  provide "marc_source.type", "xml"
end

to_field "id", extract_marc("907a", :first => true) do |marc_record, accumulator, context|
    accumulator.collect! {|s| "UNC#{s.delete("b.")}"}
end

to_field "source", literal("UNC")

to_field "local_id", extract_marc("907a", :first => true) do |rec, acc|
    acc.map! {|v| v.delete(".")}
end

to_field "holdings_note", extract_marc("863:866")