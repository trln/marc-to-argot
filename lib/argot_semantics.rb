# Encoding: UTF-8

require 'traject/marc_extractor'

module Traject::Macros

    module ArgotSemantics
        # shortcut
        MarcExtractor = Traject::MarcExtractor

        ################################################
        # Lambda for Title
        ######
        def argot_title_object(spec)
            lambda do |record,accumulator|
                st = ArgotSemantics.get_title_object(record,spec)
                accumulator << st if st
            end
        end

        ################################################
        # Create a nested title object
        ######
        def self.get_title_object(record,extract_fields = "245")
            titleobject = {
                :sort => Marc21Semantics.get_sortable_title(record),
                :alt => []
            }

            vernacular_bag = ArgotSemantics.create_vernacular_bag(record,extract_fields)

            Traject::MarcExtractor.cached(extract_fields, :alternate_script => false).each_matching_line(record) do |field, spec, extractor|
                str = extractor.collect_subfields(field, spec).first

                marc_match_suffix = ''

                field.subfields.each do |subfield|
                    if subfield.code == '6'
                        marc_match_suffix = subfield.value[subfield.value.index("-")..-1]
                    end
                end

                vernacular = vernacular_bag[field.tag + marc_match_suffix]

                case field.tag
                when '245'
                    key = 'main';
                when '210'
                    key = 'abbrv'
                when '130'
                    key = 'journal'
                when '242'
                    key = 'translation'
                else
                    key = 'alt'
                end

                titlehash = {
                    :value => str,
                    :marc => field.tag
                }
                titlehash[:vernacular] = vernacular if vernacular

                if !titleobject.key?(key)
                    titleobject[key] = []
                end
                titleobject[key] << titlehash
            end

            titleobject
        end


        ################################################
        # Lambda for Authors
        ######
        def argot_get_authors(spec)
            lambda do |record,accumulator|
                st = ArgotSemantics.get_authors(record,spec)
                accumulator << st if st
            end
        end

        ################################################
        # Create a nested authors object
        ######
        def self.get_authors(record,extract_fields = "100")
             authors = {
                :sort => Marc21Semantics.get_sortable_author(record),
                :director => []
            }

            vernacular_bag = ArgotSemantics.create_vernacular_bag(record,extract_fields)

            Traject::MarcExtractor.cached(extract_fields, :alternate_script => false).each_matching_line(record) do |field, spec, extractor|
                str = extractor.collect_subfields(field, spec).first

                marc_match_suffix = ''
                has_director = false

                field.subfields.each do |subfield|
                    if subfield.code == '6'
                        marc_match_suffix = subfield.value[subfield.value.index("-")..-1]
                    end
                    if subfield.code == '4' && subfield.value == 'drt'
                        has_director = true
                    end
                end

                author_hash = {
                    :name => str,
                    :marc => field.tag
                } 
                vernacular = vernacular_bag[field.tag + marc_match_suffix]
                author_hash[:vernacular] = vernacular if vernacular

                if field.tag.to_i < 700
                    key = 'main'
                elsif field.tag == '720'
                    key = 'uncontrolled'
                else
                    key = 'other'
                end

                authors[:director] << author_hash if has_director  

                if !authors.key?(key)
                    authors[key] = []
                end
                authors[key] << author_hash
            end

            #cleanup
            authors.each do |k,v|
                if v.empty?
                    authors.delete(k)
                end
            end

            authors
        end

        ################################################
        # Lambda for Publisher
        ######
        def argot_publisher_object
            lambda do |record,accumulator|
                st = ArgotSemantics.get_publisher_object(record)
                accumulator << st if st
            end
        end

        ##########################################
        # Create a nested publisher object
        ######
        def self.get_publisher_object(record)

            publisher = {
                :number => '',
                :name => '',
                :imprint => '',
                :marc => '',
            }

            number = Traject::MarcExtractor.cached('028ab', :alternate_script => false, :first => true).extract(record)
            if !number.empty?
                publisher[:number] = number.join("")
            end


            vernacular_bag = ArgotSemantics.create_vernacular_bag(record,"260:264")

            marc_match_suffix = ''
            name = []
            imprint = []

            Traject::MarcExtractor.cached('264b', :alternate_script => false).each_matching_line(record) do |field, spec, extractor|

                if field.indicator2 == 1
                    field.subfields.each do |subfield|
                        if subfield.code == '6'
                            marc_match_suffix = subfield.value[subfield.value.index("-")..-1]
                        end

                        if subfield.code == 'b'
                            publisher << subfield.value
                        end

                        if ['a','b','c'].include?(subfield.code)
                            imprint << subfield.value
                        end
                    end

                    vernacular = vernacular_bag[field.tag + marc_match_suffix];
                    publisher[:vernacular] = vernacular if vernacular

                    if imprint != ''
                        publisher[name] = name.join(" ")
                        publisher[imprint] = imprint.join(" ")
                        publisher[marc] = '264'
                    end
                end
            end

            if publisher[:imprint] == ''

                Traject::MarcExtractor.cached('260', :alternate_script => false).each_matching_line(record) do |field, spec, extractor|

                    field.subfields.each do |subfield|
                        if subfield.code == '6'
                            marc_match_suffix = subfield.value[subfield.value.index("-")..-1]
                        end

                        if subfield.code == 'b' || subfield.code == 'f'
                            name << subfield.value
                        end

                        if ['a','b','c','e','f','g'].include?(subfield.code)
                            imprint << subfield.value
                        end
                    end

                    vernacular = vernacular_bag[field.tag + marc_match_suffix];
                    if vernacular
                        publisher[:vernacular] = vernacular
                    end

                    if imprint != ''
                        publisher[:name] = name.join(" ")
                        publisher[:imprint] = imprint.join(" ")
                        publisher[:marc] = '260'
                    end

                end
            end

            publisher
        end

        ################################################
        # Lambda for Series
        ######
        def argot_series(extract_fields)
            lambda do |record,accumulator|
                vernacular_bag = ArgotSemantics.create_vernacular_bag(record,extract_fields)

                Traject::MarcExtractor.cached(extract_fields, :alternate_script => false).each_matching_line(record) do |field, spec, extractor|

                    series = {}
                    series_issn = nil

                    str = extractor.collect_subfields(field,spec).first

                    marc_match_suffix = ''

                    field.subfields.each do |subfield|
                        if subfield.code == '6'
                            marc_match_suffix = subfield.value[subfield.value.index("-")..-1]
                        end
                        if subfield.code == 'x'
                            case field.tag
                                when 440
                                    series_issn = subfield.value
                                when 490
                                    if field.indicator1 == '0'
                                        series_issn = subfield.value
                                    end
                                else
                            end
                        end
                    end

                    vernacular = vernacular_bag[field.tag + marc_match_suffix]

                    series[:value] = str
                    series[:issn] = series_issn if series_issn
                    series[:vernacular] = vernacular if vernacular

                    if !series.empty?
                        accumulator << series
                    end
                end
            end
        end

        ################################################
        # Lambda for Generic Vernacular Object
        ######
        def argot_gvo(extract_fields)
            lambda do |record,accumulator|
                vernacular_bag = ArgotSemantics.create_vernacular_bag(record,extract_fields)

                Traject::MarcExtractor.cached(extract_fields, :alternate_script => false).each_matching_line(record) do |field, spec, extractor|

                    gvo = {}

                    str = extractor.collect_subfields(field,spec).first

                    marc_match_suffix = ''

                    field.subfields.each do |subfield|
                        if subfield.code == '6'
                            marc_match_suffix = subfield.value[subfield.value.index("-")..-1]
                        end
                    end

                    vernacular = vernacular_bag[field.tag + marc_match_suffix]

                    gvo[:value] = str
                    gvo[:marc] = field.tag
                    gvo[:vernacular] = vernacular if vernacular

                    if !gvo.empty?
                        accumulator << gvo if str
                    end
                end

            end
        end

        ################################################
        # Lambda for Title
        ######
        def argot_linking_object(spec)
            lambda do |record,accumulator|
                st = ArgotSemantics.get_linking_object(record,spec)
                accumulator << st if st
            end
        end

        ################################################
        # Create a nested title object
        ######
        def self.get_linking_object(record,extract_fields = "765")
            linkingObject = {}

            Traject::MarcExtractor.cached(extract_fields, :alternate_script => false).each_matching_line(record) do |field, spec, extractor|
                str = extractor.collect_subfields(field, spec).first

                case field.tag
                when '760'
                    key = 'main_series';
                when '762'
                    key = 'subseries'
                when '765'
                    key = 'translation_of_title'
                when '767'
                    key = 'translated_as_title'
                when '770'
                    key = 'has_supplement'
                when '772'
                    key = 'supplement_to'
                when '773'
                    key = 'host_item_title'
                when '774'
                    key = 'constituent_unit_title'
                else
                    key = 'added_entry'
                end

                isn = field.select { |subfield| subfield.code == 'x' or subfield.code == 'z' }


                linkHash = {
                    :value => str,
                    :marc => field.tag
                }
                linkHash[:isn] = isn if isn
                if !linkingObject.key?(key)
                    linkingObject[key] = []    
                end
                linkingObject[key] << linkHash
            end

            linkingObject
        end

        ################################################
        # Lambda for Holdings (Items)
        ######
        def argot_holdings_object(extract_fields,mappings)
            lambda do |record,accumulator|
                Traject::MarcExtractor.cached(extract_fields, :alternate_script => false).each_matching_line(record) do |field, spec, extractor|
                    item = {}

                    field.subfields.each do |subfield|
                        if mappings.key?(subfield.code)
                            if !item.key?(subfield.code)
                                item[mappings[subfield.code]] = []
                            end
                            item[mappings[subfield.code]] << subfield.value
                        end
                    end

                    accumulator << item.each_key {|x| item[x] = item[x].join('--')  } if item
                end
            end
        end

        ################################################
        # Create a bag of vernacular strings to pair with other marc fields
        ######
        def self.create_vernacular_bag(record, extract_fields)
            vernacular_bag = {}

            Traject::MarcExtractor.cached(extract_fields, :alternate_script => :only).collect_matching_lines(record) do |field, spec, extractor|

                str = extractor.collect_subfields(field, spec).first

                field.subfields.each do |subfield|
                    if subfield.code == '6'
                        index_of_slash = subfield.value.rindex("/")
                        lang_code = subfield.value[index_of_slash + 1..-1] if index_of_slash
                        marc_match = subfield.value[0..index_of_slash - 1] if index_of_slash

                        case (lang_code)
                            when "(3"
                                lang = "ara"
                            when "(B"
                                lang = "lat"
                            when "$1"
                                lang = "cjk"
                            when "(N"
                                lang = "rus"
                            when "(S"
                                lang = "gre"
                            when "(2"
                                lang = "heb"
                        end


                        vernacular_bag[marc_match] = {
                            :lang_code => lang,
                            :value => str
                        }
                    end
                end
            end

            vernacular_bag
        end

    end
end