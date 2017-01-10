settings do
  provide "marc_source.type", "xml"
end

item_mappings = {
  'b' => 'barcode',
  'c' => 'copy_number',
  'd' => 'due_date',
  'i' => 'ils_id',
  'l' => 'location',
  'n' => 'note',
  'o' => 'checkouts',
  'p' => 'call_number_tag',
  'q' => 'classification_number',
  's' => 'status',
  't' => 'type',
  'v' => 'volume'
}

to_field "id", extract_marc("907a", :first => true) do |marc_record, accumulator, context|
    accumulator.collect! {|s| "UNC#{s.delete("b.")}"}
end

to_field "source", literal("UNC")

to_field "local_id", extract_marc("907a", :first => true) do |rec, acc|
    acc.map! {|v| v.delete(".")}
end

to_field "holdings_note", extract_marc("863:866")

to_field "holdings", argot_holdings_object("999", item_mappings)