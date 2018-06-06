################################################
# IDs and Standard Numbers
######

unless settings["override"].include?("id")
  to_field "id", oclcnum("035a:035z")
end

unless settings["override"].include?("record_data_source")
  to_field "record_data_source" do |rec, acc|
    acc << 'ILSMARC'
  end
end

unless settings["override"].include?("local_id")
  to_field "local_id" do |rec,acc,context|
    local_id = {
      value: context.output_hash["id"].first,
      other: []
    }
    acc << local_id
  end
end

unless settings["override"].include?("oclc_number")
  to_field "oclc_number", argot_oclc_number(settings["specs"][:oclc_number])
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
  to_field "rollup_id", argot_rollup_id("035a")
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

unless settings["override"].include?("misc_id")
  to_field "misc_id", misc_id
end

unless settings["override"].include?("upc")
  to_field "upc", upc
end

################################################
# Dates
######

unless settings["override"].include?("publication_year")
  to_field "publication_year", marc_publication_date
end

unless settings['override'].include?('date_cataloged')
    to_field 'date_cataloged' do |rec, acc|
      cataloged = Traject::MarcExtractor.cached(settings['specs'][:date_cataloged]).extract(rec).first
      acc << Time.parse(cataloged).utc.iso8601 if cataloged =~ /\A?[0-9]*\.?[0-9]+\Z/
    end
end

################################################
# Language
######

unless settings['override'].include?('lang')
  to_field 'language', argot_languages
end

unless settings["override"].include?("lang_code")
  to_field "lang_code", extract_marc("008[35-37]")
end

################################################
# Publisher
######

unless settings["override"].include?("imprint_main")
  to_field "imprint_main", imprint_main
end

unless settings["override"].include?("imprint_multiple")
  to_field "imprint_multiple", imprint_multiple
end

unless settings["override"].include?("publisher")
  to_field "publisher", extract_marc(settings["specs"][:publisher], :separator => nil, :trim_punctuation => true)
end

################################################
# Authors
######

unless settings["override"].include?("authors")
  to_field "authors", argot_authors(settings["specs"][:authors])
end

unless settings["override"].include?("author_facet")
  to_field "author_facet", argot_author_facet(settings["specs"][:author_facet])
end

################################################
# Title
######

unless settings["override"].include?("title")
  to_field "title", argot_title(settings["specs"][:title])
end

unless settings["override"].include?("title_variant")
  to_field "title_variant", title_variant
end

################################################
# Work Entry: Related Work, Included Work,
#             Series Work, This Work
######

unless settings["override"].include?("included_work")
  to_field "included_work", included_work
end

unless settings["override"].include?("related_work")
  to_field "related_work", related_work
end

unless settings["override"].include?("series_work")
  to_field "series_work", series_work
end

unless settings["override"].include?("this_work")
  to_field "this_work", this_work
end

################################################
# Notes
######

unless settings["override"].include?("note_access_restrictions")
  to_field "note_access_restrictions", note_access_restrictions
end

unless settings["override"].include?("note_admin_history")
  to_field "note_admin_history", extract_marc(settings["specs"][:note_admin_history])
end

unless settings["override"].include?("note_binding")
  to_field "note_binding", note_binding
end

unless settings["override"].include?("note_biographical")
  to_field "note_biographical", note_biographical
end

unless settings["override"].include?("note_copy_version")
  to_field "note_copy_version", note_copy_version
end

unless settings["override"].include?("note_data_quality")
  to_field "note_data_quality", note_data_quality
end

unless settings["override"].include?("note_dissertation")
  to_field "note_dissertation", note_dissertation
end

unless settings["override"].include?("note_file_type")
  to_field "note_file_type", extract_marc(settings["specs"][:note_file_type])
end

unless settings["override"].include?("note_former_title")
  to_field "note_former_title", extract_marc(settings["specs"][:note_former_title])
end

unless settings["override"].include?("note_general")
  to_field "note_general", note_general
end

unless settings["override"].include?("note_issuance")
  to_field "note_issuance", extract_marc(settings["specs"][:note_issuance])
end

unless settings["override"].include?("note_local")
  to_field "note_local", note_local
end

unless settings["override"].include?("note_methodology")
  to_field "note_methodology", extract_marc(settings["specs"][:note_methodology])
end

unless settings["override"].include?("note_numbering")
  to_field "note_numbering", extract_marc(settings["specs"][:note_numbering])
end

unless settings["override"].include?("note_organization")
  to_field "note_organization", note_organization
end

unless settings["override"].include?("note_performer_credits")
  to_field "note_performer_credits", note_performer_credits
end

unless settings["override"].include?("note_production_credits")
  to_field "note_production_credits", extract_marc(settings["specs"][:note_production_credits])
end

unless settings["override"].include?("note_related_work")
  to_field "note_related_work", note_related_work
end

unless settings["override"].include?("note_report_coverage")
  to_field "note_report_coverage", extract_marc(settings["specs"][:note_report_coverage])
end

unless settings["override"].include?("note_report_type")
  to_field "note_report_type", extract_marc(settings["specs"][:note_report_type])
end

unless settings["override"].include?("note_reproduction")
  to_field "note_reproduction", note_reproduction
end

unless settings["override"].include?("note_scale")
  to_field "note_scale", extract_marc(settings["specs"][:note_scale])
end

unless settings["override"].include?("note_summary")
  to_field "note_summary", argot_note_summary(settings["specs"][:note_summary])
end

unless settings["override"].include?("note_supplement")
  to_field "note_supplement", extract_marc(settings["specs"][:note_supplement])
end

unless settings["override"].include?("note_system_details")
  to_field "note_system_details", note_system_details
end

unless settings["override"].include?("note_toc")
  to_field "note_toc", argot_note_toc(settings["specs"][:note_toc])
end

unless settings["override"].include?("note_with")
  to_field "note_with", extract_marc(settings["specs"][:note_with])
end

unless settings["override"].include?("note_serial_dates")
  to_field "note_serial_dates", note_serial_dates
end

################################################
# Physical Description
######

unless settings["override"].include?("physical_description")
  to_field "physical_description", physical_description
end

unless settings["override"].include?("physical_description_details")
  to_field "physical_description_details", physical_description_details
end

################################################
# URLs
######

unless settings["override"].include?("url")
  to_field "url", url
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

unless settings['override'].include?('subject_topic_lcsh')
  to_field 'subject_topic_lcsh', argot_subjects({ spec: '600|*0|abcdfghjklmnopqrstu:600|*0|x:'\
                                                        '610|*0|abcdfghklmnoprstu:610|*0|x:'\
                                                        '611|*0|acdefghklnpqstu:611|*0|x:'\
                                                        '630|*0|adfghklmnoprst:630|*0|x:'\
                                                        '647|*0|acdg:647|*0|x:'\
                                                        '648|*0|x:'\
                                                        '650|*0|abcdg:650|*0|x:'\
                                                        '651|*0|x' })

  to_field 'subject_topic_lcsh', argot_subjects({ spec: '600|*7|abcdfghjklmnopqrstu:600|*7|x:'\
                                                        '610|*7|abcdfghklmnoprstu:610|*7|x:'\
                                                        '611|*7|acdefghklnpqstu:611|*7|x:'\
                                                        '630|*7|adfghklmnoprst:630|*7|x:'\
                                                        '647|*7|acdg:647|*7|x:'\
                                                        '648|*7|x:'\
                                                        '650|*7|abcdg:650|*7|x:'\
                                                        '651|*7|x:'\
                                                        '656|*7|x:656|*7|a:'\
                                                        '657|*7|x:657|*7|a',
                                                  classifications: /lcsh/ })
end

unless settings['override'].include?('subject_chronological')
  to_field 'subject_chronological', argot_subjects({ spec: '600|*0|y:610|*0|y:611|*0|y:630|*0|y:'\
                                                           '648|*0|a:650|*0|y:651|*0|y:655|*0|y' })

  to_field 'subject_chronological', argot_subjects({ spec: '600|*7|y:610|*7|y:611|*7|y:630|*7|y:'\
                                                           '650|*7|y:651|*7|y:655|*7|y',
                                                     classifications: /lcsh/ })

  to_field 'subject_chronological', argot_subjects({ spec: '648|*7|a',
                                                     classifications: /lcsh|fast/ })
end

unless settings['override'].include?('subject_geographic')
  to_field 'subject_geographic', argot_subjects({ spec: '600|*0|z:610|*0|z:611|*0|z:630|*0|z:'\
                                                        '648|*0|z:650|*0|z:651|*0|z:655|*0|z'})

  to_field 'subject_geographic', argot_subjects({ spec: '600|*7|z:610|*7|z:611|*7|z:630|*7|z:'\
                                                        '650|*7|z:651|*7|z:655|*7|z',
                                                  classifications: /lcsh/ })

  to_field 'subject_geographic', argot_subjects({ spec: '648|*7|z',
                                                  classifications: /lcsh|fast/ })
end

unless settings['override'].include?('subject_genre')
  to_field 'subject_genre', argot_subjects({ spec: '600|*0|v:610|*0|v:611|*0|v:630|*0|v:647|*0|v:'\
                                                   '648|*0|v:650|*0|v:651|*0|v:655|*0|v'})

  to_field 'subject_genre', argot_subjects({ spec: '600|*7|v:610|*7|v:611|*7|v:630|*7|v:647|*7|v:'\
                                                   '648|*7|v:650|*7|v:651|*7|v:656|*7|v:656|*7|k:657|*7|v',
                                             classifications: /lcsh/})

  to_field 'subject_genre', argot_subjects({ spec: '655|*7|v',
                                             classifications: /lcsh|lcgft|rbbin|rbgenr|rbprov/})

  to_field 'subject_genre', argot_subjects({ spec: '655|*7|ax:655|*0|ax',
                                             classifications: /lcsh|lcgft|rbbin|rbgenr/,
                                             subdivison_separator: ' -- ' })

  to_field 'subject_genre', argot_subjects({ spec: '655|*7|ax',
                                             classifications: /rbprov/,
                                             subdivison_separator: ' -- ',
                                             filter_method: :strip_provenance })

  to_field 'subject_genre', argot_genre_special_cases()
  to_field 'subject_genre', argot_genre_special_cases({ spec: '006[16]:006[17]',
                                                        mapped_byte: 16,
                                                        bio_byte: 17,
                                                        constraint: :field_006_byte_00_at })
end

################################################
# Format -- Resource Type, Characteristics, Physical Media, etc.
######

unless settings['override'].include?('access_type')
  to_field 'access_type' do |rec, acc|
    acc << 'Online' if online_access?(rec)
    acc << 'At the Library' if physical_access?(rec)
  end
end

unless settings['override'].include?('resource_type')
  to_field 'resource_type', resource_type
end

unless settings['override'].include?('physical_media')
  to_field 'physical_media', physical_media
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

unless settings["override"].include?("series")
  to_field "series", argot_series(settings["specs"][:series])
end

unless settings['override'].include?('institution')
  to_field 'institution' do |rec, acc|
    inst = %w[unc duke nccu ncsu]
    acc.concat(inst)
  end
end

# Other fields in endeca model that we're unsure how to map to
# source_of_acquisition
# related_collections
# biographical_sketch
# most_recent
# holdings_note
