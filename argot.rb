$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), './lib'))


# A sample traject configuration, save as say `traject_config.rb`, then
# run `traject -c traject_config.rb marc_file.marc` to index to
# solr specified in config file, according to rules specified in
# config file


# To have access to various built-in logic
# for pulling things out of MARC21, like `marc_languages`
require 'traject/macros/marc21_semantics'
extend  Traject::Macros::Marc21Semantics

# To have access to the traject marc format/carrier classifier
require 'traject/macros/marc_format_classifier'
extend Traject::Macros::MarcFormats

require 'argot_semantics'
extend Traject::Macros::ArgotSemantics

require 'argot_writer'

# list of attributes to "de-arrayify"
# Traject treats all attributes as an array
# but we want a nested, readable, JSON structure for some attributes (like title and id)
# anything in the array below will have the attribute array become a standard object/hash

flatten_attributes = %w(
    title
    authors
    publication_year
    local_id
    source
    id
    lang
    lang_code
)

# In this case for simplicity we provide all our settings, including
# solr connection details, in this one file. But you could choose
# to separate them into antoher config file; divide things between
# files however you like, you can call traject with as many
# config files as you like, `traject -c one.rb -c two.rb -c etc.rb`
settings do
  provide "writer_class_name", "Traject::ArgotWriter"
  provide "output_file", "argot_out.json"
  provide 'processing_thread_pool', 3
  provide "argot_writer.pretty_print", true
  provide "argot_writer.flatten_attributes", flatten_attributes
end


title_specs = %w(
    245abnp
    210ab
    130adfghklmnoprs
    242abhnp
    246abhnp
    247abhnp
    730adfghklmnoprst
    740ahnp
    780abcdghnkstxz
    785abcdghikmnstxz
)
to_field "title", argot_title_object(title_specs.join(":"))
to_field "statement_of_responsibility", argot_gvo("245c")
to_field "edition", argot_gvo("250ab:775abdghint")
to_field "publication_year", marc_publication_date
to_field "authors", argot_get_authors("100abcdegq:110abcdefgn:111abcdefngq:700abcdeq:710abcde:711abcdeq:720a")
to_field "lang_code", extract_marc("008[35-37]")
to_field "lang", extract_marc("008[35-37]:041a:041d", :translation_map => "marc_languages")

######
# Series
######
to_field "series_statement", argot_series("440anpvx")
to_field "series_statement", argot_series("490avx")
to_field "series", extract_marc("800abcdefhklmnopqrstv:810abcdefhklmnoprstv:811acdefhklnpqstv:830adfghklmnoprsv")
to_field "series_title_index", extract_marc("800tnpfkl:810tnoprlsm:811tnpls:830ahnpv")

#####

######
# Notes
######
notes_indexed_specs = %w(
    500a
    501a
    502a
    504a
    505argt
    507ab
    522a
    533cf
    534abcefnpt
    536abcdefgh
    544abcden
    545abu
    581a
    585a
    586a
)
to_field "notes_indexed", argot_gvo(notes_indexed_specs.join(":"))

notes_additional_specs = %w(
    506abcdeu
    508a
    510abcx
    511a
    513ab
    514abcdefghijkmuz
    515a
    516a
    518a
    520abu
    521ab
    524a
    525a
    530abcu
    533abcdefmn
    535abdcdg
    540abu3
    541abcdefhno
    541a
    546ab
    547a
    550a
    555abcdu
    556a
    561a
    563a
    565abdce
    567a
    580a
    588a
    590a
    599ab
    752abcd
)
to_field "notes_additional", argot_gvo(notes_additional_specs.join(":"))

subjects_specs = %w(
    600abcdefghijklmnopqrstvxyz
    610abcdefghijklmnopqrstvxyz
    611acdefghijklmnopqrstvxyz
    630adfghklmnoprstvxyz
    650abcdevxyz
    651avxyz
    653a
    655abvxyz
    690ax
    691abvxyz
    695a
)
to_field "subjects", marc_lcsh_formatted({:spec => subjects_specs.join(":"), :subdivison_separator => " -- "})

######
# ISBN / ISSN / UPC
#####
to_field "isbn", extract_marc("020az:024a")
to_field "syndetics_isbn", extract_marc("020a")
to_field "issn", extract_marc("022ayz")
to_field "upc" do |record, acc|
    Traject::MarcExtractor.cached("024a").each_matching_line(record) do |field, spec, extractor|
        if field.indicator1 == '1'
            acc << extractor.collect_subfields(field,spec).first
        end
    end
end

######
# Publisher
######
to_field "publisher", argot_publisher_object

######
# Frequency
######
to_field "frequency_current", extract_marc("310ab")
to_field "frequency_former", extract_marc("321ab")

######
# URLS
######
to_field "url" do |record, acc|
    Traject::MarcExtractor.cached("856uyz3").each_matching_line(record) do |field, spec, extractor|
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

######
# MISC
######
to_field "cartographic_data", extract_marc("255abcdefg")
to_field "sound_recording_display", extract_marc("262abcde")
to_field "sound_recording_indexed", extract_marc("262b")
to_field "characteristics_sound", extract_marc("344abcdefgh3")
to_field "characteristics_projection", extract_marc("345ab3")
to_field "characteristics_video", extract_marc("346ab3")
to_field "characteristics_digital_file", extract_marc("347abcdef3")
to_field "organization_arrangement", extract_marc("351a")
to_field "volume_date_range", extract_marc("362a")
to_field "data_cataloged", extract_marc("909")

######
# Additional 264 RDA
######
to_field "production_statement" do |record, acc|
   Traject::MarcExtractor.cached("264abc").each_matching_line(record) do |field, spec, extractor|
       if field.indicator2 == '0'
           acc << extractor.collect_subfields(field,spec).first
       end
   end
end
to_field "production_statement" do |record, acc|
   Traject::MarcExtractor.cached("264abc").each_matching_line(record) do |field, spec, extractor|
       if field.indicator2 == '0'
           acc << extractor.collect_subfields(field,spec).first
       end
   end
end
to_field "producer" do |record, acc|
   Traject::MarcExtractor.cached("264b").each_matching_line(record) do |field, spec, extractor|
       if field.indicator2 == '0'
           acc << extractor.collect_subfields(field,spec).first
       end
   end
end
to_field "distribution_statement" do |record, acc|
   Traject::MarcExtractor.cached("264abc").each_matching_line(record) do |field, spec, extractor|
       if field.indicator2 == '2'
           acc << extractor.collect_subfields(field,spec).first
       end
   end
end
to_field "distributor" do |record, acc|
   Traject::MarcExtractor.cached("264b").each_matching_line(record) do |field, spec, extractor|
       if field.indicator2 == '2'
           acc << extractor.collect_subfields(field,spec).first
       end
   end
end
to_field "manufacturer_statement" do |record, acc|
   Traject::MarcExtractor.cached("264abc").each_matching_line(record) do |field, spec, extractor|
       if field.indicator2 == '3'
           acc << extractor.collect_subfields(field,spec).first
       end
   end
end
to_field "manufacturer" do |record, acc|
   Traject::MarcExtractor.cached("264b").each_matching_line(record) do |field, spec, extractor|
       if field.indicator2 == '3'
           acc << extractor.collect_subfields(field,spec).first
       end
   end
end
to_field "copyright_statement" do |record, acc|
   Traject::MarcExtractor.cached("264c").each_matching_line(record) do |field, spec, extractor|
       if field.indicator2 == '4'
           acc << extractor.collect_subfields(field,spec).first
       end
   end
end
to_field "copyright" do |record, acc|
   Traject::MarcExtractor.cached("264c").each_matching_line(record) do |field, spec, extractor|
       if field.indicator2 == '4'
           acc << extractor.collect_subfields(field,spec).first
       end
   end
end


######
# Linking (leaving this flat as an additional option to the nested structure)
######
to_field "linking_main_series", extract_marc("760abcdghimnostwxy")
to_field "linking_subseries", extract_marc("762abcdghimnostwxy")
to_field "linking_translation_of_title", extract_marc("765abcdghikmnorstuwxyz")
to_field "linking_translated_as_title", extract_marc("767abcdghikmnorstuwxyz")
to_field "linking_has_supplement", extract_marc("770abcdghikmnorstuwxyz")
to_field "linkint_supplement_to", extract_marc("772abcdghikmnorstuwxyz")
to_field "linking_host_item_title", extract_marc("773abdghikmnopqrstuwxyz")
to_field "linking_constituent_unit_title", extract_marc("774abcdghikmnorstuwxyz")
to_field "linking_isn", extract_marc("765xz:767xz:773xz:774xz:780xz:785xz")
to_field "linking_added_entry", extract_marc("790a:791ab")