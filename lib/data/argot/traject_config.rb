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

unless settings['override'].include?('date_cataloged')
  to_field 'date_cataloged' do |rec, acc|
    cataloged = Traject::MarcExtractor.cached(settings['specs'][:date_cataloged]).extract(rec).first
    acc << Time.parse(cataloged).utc.iso8601 if cataloged
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

unless settings["override"].include?("author_facet")
  to_field "author_facet", argot_author_facet(settings["specs"][:author_facet])
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
# misc_ids
######

def national_bibliography_codes
  @national_bibliography_codes ||=Traject::TranslationMap.new('shared/national_bibliography_codes')
end

def clean_qualifier_sf(value)
  value.gsub!(/[()]/, '')
end

def split_qualifier(value)
  m = /^(.+?) ?\((.+)\)/.match(value)
  [m[1], m[2]]
end

def process_010(field, acc)
  # 010 defines no qualifying info field
  field.subfields.each do |sf|
    case sf.code
    when 'a'
      acc << {'value' => sf.value, 'qual' => '', 'type' => 'LCCN'}
    when 'b'
      acc << {'value' => sf.value, 'qual' => '', 'type' => 'NUCMC'}
    end
  end
end

def process_015(field, acc)
  sf_a = field.select { |sf| sf.code == 'a' }
  sf_q = field.select { |sf| sf.code == 'q' }
  sf_2 = field.select { |sf| sf.code == '2' }
  type = 'National Bibliography Number'

  if sf_2.size > 0
    type = national_bibliography_codes[sf_2[0].value]
  end

  # when $q was defined 2013, the instruction to record multiple numbers
  #  in repeating subfields was in place -- UNC catalog has no examples of
  # multiple $a with $q in the same field. When $q exists, there is only 1 $a
  if sf_a.size == 1 && sf_q.size == 1
    id = sf_a[0].value
    qual = clean_qualifier_sf(sf_q[0].value)
    acc << {'value' => id, 'qual' => qual, 'type' => type}
  # Prior to 2001, 015 field was not repeatable. $q was not defined.
  #  Multiple ids were recorded in repeated $a's, with parenthetical
  #  qualifying info as part of $a
  elsif sf_a.size > 0 && sf_q.size == 0
    sf_a.each do |sf|
      if sf.value =~ /\(.+\)/
        split = split_qualifier(sf.value)
        acc << {'value' => split[0], 'qual' => split[1], 'type' => type}
      else
        acc << {'value' => sf.value, 'qual' => '', 'type' => type}
      end
    end
  end
end

unless settings["override"].include?("misc_id")


  to_field "misc_id" do |rec, acc|
    Traject::MarcExtractor.cached('010ab:015aq2').each_matching_line(rec) do |field, spec, extractor|
      case field.tag
      when '010'
        process_010(field, acc)
      when '015'
        process_015(field, acc)
      end
    end
    acc.uniq!
  end
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
  to_field "series", argot_series(settings["specs"][:series])
end

unless settings['override'].include?('institution')
  to_field 'institution' do |rec, acc|
    inst = %w[unc duke nccu ncsu]
    acc.concat(inst)
  end
end

unless settings['override'].include?('access_type_facet')
  to_field 'access_type_facet' do |rec, acc|
    acc << 'Online' if online_access?(rec)
    acc << 'At the Library' if physical_access?(rec)
  end
end

# Other fields in endeca model that we're unsure how to map to
# source_of_acquisition
# related_collections
# biographical_sketch
# most_recent
# holdings_note
