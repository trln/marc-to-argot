## Traject configurations start by loading this file, and then they load
# institution/configuration specific files.  In order of execution, this means
# that any field that is *not* overridden in an institution/configuration
# specific file happens *after* any field that is mapped in this file.

# The loader 'includes' shared macros in this file, and includes
# institution-specific macros (if any) for the sub-configurations.
# What this means is that any macros (or methods) used in this file
# will be the 'shared' versions, which may not be what you want.

# Set up the main logger, used in macros and configuration files.
# this version uses the `logging` gem with a custom adapter, allowing
# us to set a mapped diagnostic context which can contain information about
# the record being processed
self.logger = Yell.new do |l|
  l.adapter :logging_adapter,
            level: settings.fetch(:log_level, :info),
            appender: settings.fetch(:appender, :stderr)
end

################################################
# IDs and Standard Numbers
######

#unless settings["override"].include?("id")
#  to_field "id", record_id
#end

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
    acc.uniq!
  end
end

unless settings["override"].include?("primary_isbn")
  to_field "primary_isbn" do |rec, acc|
    Traject::MarcExtractor.cached(settings["specs"][:primary_isbn], :alternate_script => false).each_matching_line(rec) do |field, spec, extractor|
      str = extractor.collect_subfields(field, spec).first
      if str
        explode = str.split
        if(StdNum::ISBN.checkdigit(explode[0]) && !explode[1..-1].join(" ").include?("exclude"))
          primary_isbn = explode[0]
        end
      end
      acc << primary_isbn if primary_isbn
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
  to_field "publication_year", publication_year
end

unless settings['override'].include?('date_cataloged')
  to_field 'date_cataloged' do |rec, acc|
    cataloged = Traject::MarcExtractor.cached(settings['specs'][:date_cataloged]).extract(rec).first.to_s.strip
    begin
      acc << Time.parse(cataloged).utc.iso8601 if cataloged =~ /\A?[0-9]*\.?[0-9]+\Z/
    rescue ArgumentError => e
      logger.error("date_cataloged value cannot be parsed: #{e}")
    end
  end
end

################################################
# Language
######

unless settings['override'].include?('lang')
  to_field 'language', language
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
  to_field "publisher", basic_vernacular_field(settings["specs"][:publisher],
                                               :separator => nil,
                                               :trim_punctuation => true)
end

unless settings["override"].include?("publisher_location")
  to_field "publisher_location", publisher_location
end

################################################
# Names
######

unless settings["override"].include?("names")
  to_field "names", names
end

unless settings['override'].include?('creator_main')
  to_field 'creator_main', creator_main
end

################################################
# Title
######

unless settings["override"].include?("title_main")
  to_field "title_main", title_main
end

unless settings['override'].include?('short_title')
  to_field 'short_title', short_title
end

unless settings["override"].include?("title_sort")
  to_field "title_sort", title_sort
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
# Series Statement
######

unless settings["override"].include?("series_statement")
  to_field "series_statement", series_statement
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

unless settings["override"].include?("note_cited_in")
  to_field "note_cited_in", note_cited_in
end

unless settings["override"].include?("note_copy_version")
  to_field "note_copy_version", note_copy_version
end

unless settings["override"].include?("note_data_quality")
  to_field "note_data_quality", note_data_quality
end

unless settings["override"].include?("note_described_by")
  to_field "note_described_by", note_described_by
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

unless settings["override"].include?("note_preferred_citation")
  to_field 'note_preferred_citation', note_preferred_citation
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
  to_field "note_with", note_with
end

unless settings["override"].include?("note_serial_dates")
  to_field "note_serial_dates", note_serial_dates
end

unless settings["override"].include?("note_use_terms")
  to_field 'note_use_terms', note_use_terms
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
# Subject & Genre Headings
######

unless settings["override"].include?("subject_headings")
  to_field 'subject_headings', subject_headings
  each_record do |rec, acc|
  end
end

unless settings["override"].include?("genre_headings")
  to_field 'genre_headings', genre_headings
end

################################################
# Subject & Genre Facets
######

unless settings['override'].include?('subject_topical')
  to_field 'subject_topical', subject_topical
end

unless settings['override'].include?('subject_chronological')
  to_field 'subject_chronological', subject_chronological
end

unless settings['override'].include?('subject_geographic')
  to_field 'subject_geographic', subject_geographic
end

unless settings['override'].include?('subject_genre')
  to_field 'subject_genre', subject_genre
end

################################################
# Remap problematic subject headings
######
unless settings['override'].include?('subject_headings') || settings['override'].include?('subject_topical')

  each_record do |rec, cxt|
    remap_subjects(rec, cxt)
  end
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

unless settings['override'].include?('available')
  each_record do |rec, context|
    if context.output_hash['access_type'] == ['Online']
      context.output_hash['available'] = 'Available'
    end
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
  to_field "statement_of_responsibility", statement_of_responsibility
end

unless settings["override"].include?("edition")
  to_field "edition", edition
end

unless settings["override"].include?("frequency")
  to_field "frequency", argot_frequency(settings["specs"][:frequency])
end

unless settings['override'].include?('institution')
  to_field 'institution' do |rec, acc|
    inst = %w[unc duke nccu ncsu]
    acc.concat(inst)
  end
end

unless settings['override'].include?('access_type')
  each_record do |rec, cxt|
    access_type = cxt.output_hash['access_type']
    if access_type
      physical_media = cxt.output_hash['physical_media']
      if physical_media
        physical_media << 'Online' if access_type.include?('Online')
      else
        cxt.output_hash['physical_media'] = ['Online'] if access_type.include?('Online')
      end
    end
  end
end

unless settings['override'].include?('origin_place_search')
  to_field 'origin_place_search', origin_place_search
end

unless settings['override'].include?('origin_place_facet')
  to_field 'origin_place_facet', origin_place_facet
end
