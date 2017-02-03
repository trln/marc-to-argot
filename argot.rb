# list of top-level hashes in the argot model, they should be "de-arrayified"
# Traject treats all attributes as an array
# but we want a nested, readable, JSON structure for some attributes (like title and id)
# anything in the array below will have the attribute array become a standard object/hash

flatten_attributes = %w(
    id
    oclc_number
    local_id
    rollup_id
    ead_id
    isbn
    issn
    lang_code
    authors
    title
    notes
    url
    linking
    frequency
    description
    series
)

# In this case for simplicity we provide all our settings, including
# solr connection details, in this one file. But you could choose
# to separate them into antoher config file; divide things between
# files however you like, you can call traject with as many
# config files as you like, `traject -c one.rb -c two.rb -c etc.rb`
settings do
  provide "argot_writer.flatten_attributes", flatten_attributes
  provide "writer_class_name", "Traject::ArgotWriter"
end


################################################
# IDs and Standard Numbers
######

if !settings["override"].include?("id")
  to_field "id", oclcnum("035a:035z")
end

if !settings["override"].include?("oclc_number")
  to_field "oclc_number", argot_oclc_number(settings["specs"][:oclc])
end

if !settings["override"].include?("syndetics_id")
  to_field "syndetics_id", extract_marc(settings["specs"][:syndetics_id], :separator=>nil) do |rec, acc|
    orig = acc.dup
    acc.map!{|x| StdNum::ISBN.allNormalizedValues(x)}
    acc.flatten!
    acc.uniq!
  end
end

if !settings["override"].include?("ead_id")
  # to_field "ead_id", literal("")
end

if !settings["override"].include?("rollup_id")
  to_field "id", oclcnum("035a:035z")
end

if !settings["override"].include?("isbn")
  to_field "isbn", argot_isbn(settings["specs"][:isbn])
end

if !settings["override"].include?("issn")
  to_field "issn", argot_issn(settings["specs"][:issn])
end

################################################
# Dates
######

if !settings["override"].include?("publication_year")
  to_field "publication_year", marc_publication_date
end

if !settings["override"].include?("copyright_date")
  to_field "copyright_date" do |record, acc|
     Traject::MarcExtractor.cached("264c").each_matching_line(record) do |field, spec, extractor|
         if field.indicator2 == '4'
             acc << extractor.collect_subfields(field,spec).first
         end
     end
  end
end

################################################
# Language
######

if !settings["override"].include?("lang")
  to_field "language", extract_marc("008[35-37]:041a:041d", :translation_map => "marc_languages")
end

if !settings["override"].include?("lang_code")
  to_field "lang_code", extract_marc("008[35-37]")
end

################################################
# Publisher
######

if !settings["override"].include?("publisher_number")
  to_field "publisher_number", extract_marc(settings["specs"][:publisher_number])
end

if !settings["override"].include?("publisher_etc")
  to_field "publisher_etc", argot_publisher(settings["specs"][:publisher_etc])
end

if !settings["override"].include?("imprint")
  to_field "imprint", argot_imprint(settings["specs"][:imprint])
end

################################################
# Authors
######

if !settings["override"].include?("authors")
  to_field "authors", argot_authors(settings["specs"][:authors])
end

################################################
# Title
######

if !settings["override"].include?("title")
  to_field "title", argot_title(settings["specs"][:title])
end

################################################
# Notes
######

if !settings["override"].include?("notes")
  to_field "notes", argot_notes(settings["specs"][:notes])
end

################################################
# URLs
######

if !settings["override"].include?("url")
  to_field "url" do |rec, acc|
      Traject::MarcExtractor.cached("856uyz3").each_matching_line(rec) do |field, spec, extractor|
          url = {}
          if field.indicator2.to_i > 1
              url[:rel] = 'secondary'
          else
              url[:rel] = 'primary'
          end

          field.subfields.each do |subfield|
              if subfield.code == 'u'
                  url[:href] = subfield.value
              elsif subfield.code == '3' && subfield.value == 'Finding Aid'
                  url[:rel] = 'finding_aid'
              else
                  url[:text] = subfield.value
              end
          end

          acc << url
     end
  end
end

################################################
# Linking
######

if !settings["override"].include?("linking")
  to_field "linking", argot_linking_attributes(settings["specs"][:linking])
end

################################################
# Format
######

if !settings["override"].include?("format")
  to_field "format", marc_formats
end

################################################
# Subjects
######

if !settings["override"].include?("subjects")
  to_field "subjects", marc_lcsh_formatted({:spec => settings["specs"][:subjects], :subdivison_separator => " -- "})
end

################################################
# Additional
######

if !settings["override"].include?("statement_of_responsibility")
  to_field "statement_of_responsibility", argot_gvo(settings["specs"][:statement_of_responsibility])
end

if !settings["override"].include?("edition")
  to_field "edition", argot_gvo(settings["specs"][:edition])
end

if !settings["override"].include?("frequency")
  to_field "frequency", argot_frequency(settings["specs"][:frequency])
end

if !settings["override"].include?("description")
  to_field "description", argot_description(settings["specs"][:description])
end

if !settings["override"].include?("series")
  to_field "series", argot_series(settings["specs"][:description])
end

if !settings["override"].include?("institution")
  to_field "institution" do |rec, acc|
    inst = %w(unc duke nccu ncsu)
    acc.concat(inst)
  end
end


# Other fields in endeca model that we're unsure how to map to
# source_of_acquisition
# related_collections
# biographical_sketch
# most_recent
# holdings_note

