################################################
# IDs and Standard Numbers
######

unless settings["override"].include?("id")
  to_field "id", oclcnum("035a:035z")
end

unless settings["override"].include?("local_id")
  to_field "local_id" do |rec,acc,context|

    local_id = {
      :value => context.output_hash["id"].first,
      :other => []
    }
    acc << local_id

  end
end

unless settings["override"].include?("oclc_number")
  to_field "oclc_number", argot_oclc_number(settings["specs"][:oclc])
end

unless settings["override"].include?("syndetics_id")
  to_field "syndetics_id", extract_marc(settings["specs"][:syndetics_id], :separator=>nil) do |rec, acc|
    orig = acc.dup
    acc.map!{|x| StdNum::ISBN.allNormalizedValues(x)}
    acc.flatten!
    acc.uniq!
  end
end

unless settings["override"].include?("ead_id")
  # to_field "ead_id", literal("")
end

unless settings["override"].include?("rollup_id")
  to_field "id", oclcnum("035a:035z")
end

unless settings["override"].include?("isbn")
  to_field "isbn" do |rec, acc|
    Traject::MarcExtractor.cached(settings["specs"][:isbn], :alternate_script => false).each_matching_line(rec) do |field, spec, extractor|
        str = extractor.collect_subfields(field, spec).first
        isbn = {}
        if str
            explode = str.split
            if(StdNum::ISBN.checkdigit(explode[0]))

                isbn = {
                    :number => explode[0],
                    :qualifying_info => explode[1..-1].join(" ")
                }
            end
        end
        acc << isbn if !isbn.empty?
    end
  end
end

unless settings["override"].include?("issn")
  to_field "issn", argot_issn(settings["specs"][:issn])
end

################################################
# Dates
######

unless settings["override"].include?("publication_year")
  to_field "publication_year", marc_publication_date
end

unless settings["override"].include?("copyright_year")
  to_field "copyright_year" do |record, acc|
    Traject::MarcExtractor.cached("264c").each_matching_line(record) do |field, spec, extractor|
       if field.indicator2 == '4'
            str = extractor.collect_subfields(field,spec).first
            acc << str.gsub!(/[^\d]/,'').to_i if str
       end
    end
  end
end

################################################
# Language
######

unless settings["override"].include?("lang")
  to_field "language", extract_marc("008[35-37]:041a:041d", :translation_map => "marc_languages")
end

unless settings["override"].include?("lang_code")
  to_field "lang_code", extract_marc("008[35-37]")
end

################################################
# Publisher
######

unless settings["override"].include?("publisher_number")
  to_field "publisher_number", extract_marc(settings["specs"][:publisher_number])
end

unless settings["override"].include?("publisher_etc")
  to_field "publisher_etc", argot_publisher(settings["specs"][:publisher_etc])
end

unless settings["override"].include?("imprint")
  to_field "imprint", argot_imprint(settings["specs"][:imprint])
end

################################################
# Authors
######

unless settings["override"].include?("authors")
  to_field "authors", argot_authors(settings["specs"][:authors])
end

################################################
# Title
######

unless settings["override"].include?("title")
  to_field "title", argot_title(settings["specs"][:title])
end

################################################
# Notes
######

unless settings["override"].include?("notes")
  to_field "notes", argot_notes(settings["specs"][:notes])
end

################################################
# URLs
######

unless settings["override"].include?("url")
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

unless settings["override"].include?("linking")
  to_field "linking", argot_linking_attributes(settings["specs"][:linking])
end

################################################
# Format
######

unless settings["override"].include?("format")
  to_field "format", marc_formats
end

################################################
# Subjects
######

unless settings["override"].include?("subjects")
  to_field "subjects", marc_lcsh_formatted({:spec => settings["specs"][:subjects], :subdivison_separator => " -- "})
end

unless settings["override"].include?("subject_genre")
  to_field "subject_genre", marc_lcsh_formatted({:spec => settings["specs"][:subject_genre], :subdivison_separator => " -- "})
end

unless settings["override"].include?("subject_medical")
  to_field "subject_medical", marc_lcsh_formatted({:spec => settings["specs"][:subject_medical], :subdivison_separator => " -- "})
end

unless settings["override"].include?("subject_region")
    to_field "subject_region", extract_marc("651a")
end

unless settings["override"].include?("subject_time_period")
  to_field "subject_time_period", marc_lcsh_formatted({:spec => settings["specs"][:subject_time_period], :subdivison_separator => " -- "})
end

################################################
# Additional
######

unless settings["override"].include?("statement_of_responsibility")
  to_field "statement_of_responsibility", argot_gvo(settings["specs"][:statement_of_responsibility])
end

unless settings["override"].include?("edition")
  to_field "edition", argot_gvo(settings["specs"][:edition])
end

unless settings["override"].include?("frequency")
  to_field "frequency", argot_frequency(settings["specs"][:frequency])
end

unless settings["override"].include?("description")
  to_field "description", argot_description(settings["specs"][:description])
end

unless settings["override"].include?("series")
  to_field "series", argot_series(settings["specs"][:description])
end

unless settings["override"].include?("institution")
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

