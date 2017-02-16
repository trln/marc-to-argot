# Encoding: UTF-8

require 'traject/marc_extractor'


module Traject::Macros

    module ArgotSemantics
        # shortcut
        MarcExtractor = Traject::MarcExtractor

        ################################################
        # Lambda for OCLC Number
        ######
        def argot_oclc_number(config)

            lambda do |rec, acc|
                
                st = {}
                config.each do |key, spec|

                    extractor = MarcExtractor.cached(spec, :separator => nil)
                    oclc_num = extractor.extract(rec).collect! do |o|
                        Marc21Semantics.oclcnum_extract(o)
                    end.compact

                    oclc_num = oclc_num.uniq

                    if key == "value"
                        st[key] = oclc_num.first if oclc_num
                    else
                        st[key] = oclc_num if !oclc_num.empty?
                    end
                end

                acc << st if !st.empty?
            end
        end

        ################################################
        # Lambda for ISBN
        ######
        def argot_isbn(config)
            lambda do |rec, acc|
                st = {}
                config.each do |key, spec|
                    isbn = ArgotSemantics.get_isbn_hash(rec, spec)
                    st[key] = isbn if isbn
                end

                acc << st if !st.empty?
            end
        end

        ################################################
        # Get an ISBN hash
        ######
        def self.get_isbn_hash(record,extract_fields)

            isbn_array = []

            Traject::MarcExtractor.new(extract_fields, :alternate_script => false).each_matching_line(record) do |field, spec, extractor|

                str = extractor.collect_subfields(field, spec).first
                isbn = {}

                if str
                    explode = str.split
                    if(StdNum::ISBN.checkdigit(explode[0]))

                        isbn = {
                            :number => explode[0],
                            :qualifying_info => explode[1..-1].join(" ")
                        }
                    
                        isbn_array << isbn
                    end
                end
            end
            isbn_array if !isbn_array.empty?
        end

        ################################################
        # Lambda for ISSN
        ######
        def argot_issn(config)
            lambda do |rec, acc|
                st = {}
                config.each do |key, spec|
                    extractor = MarcExtractor.cached(spec, :separator => nil)
                    issn = extractor.extract(rec).collect! do |o|
                        StdNum::ISSN.normalize(o)
                    end.compact

                    st[key] = issn.uniq if !issn.empty?
                end

                acc << st if !st.empty?
            end
        end

        ################################################
        # Lambda for Publisher
        ######
        def argot_publisher(spec)
            lambda do |rec, acc|
                
                vernacular_bag = ArgotSemantics.create_vernacular_bag(rec, spec)
                marc_match_suffix = ''
                publisher = {}

                Traject::MarcExtractor.cached(spec, :alternate_script => false).each_matching_line(rec) do |field, spec, extractor|

                    field.subfields.each do |subfield|
                        if subfield.code == '6'
                            marc_match_suffix = subfield.value[subfield.value.index("-")..-1]
                        end

                        if field.tag == '264'
                            if subfield.code == 'b'
                                publisher[:name] = subfield.value
                            end
                        end
                    end

                    if !publisher[:name]
                        publisher[:name] = extractor.collect_subfields(field,spec).first
                    end

                    if field.tag == '264'
                        case field.indicator2
                        when '1'
                            publisher[:type] = "publisher"
                        when '0'
                            publisher[:type] = "producer"
                        when '2'
                            publisher[:type] = "distributor"
                        when '3'
                            publisher[:type] = "manufacturer"
                        else
                            publisher = {}
                        end
                    else
                        publisher[:type] = "publisher"
                    end

                    vernacular = vernacular_bag[field.tag + marc_match_suffix];
                    publisher[:vernacular] = vernacular if vernacular
                end

                acc << publisher if !publisher.empty?
            end
        end

        ################################################
        # Lambda for Imprint
        ######
        def argot_imprint(spec)
            lambda do |rec, acc|
                
                vernacular_bag = ArgotSemantics.create_vernacular_bag(rec, spec)
                marc_match_suffix = ''
                imprint = {}

                Traject::MarcExtractor.cached(spec, :alternate_script => false).each_matching_line(rec) do |field, spec, extractor|

                    field.subfields.each do |subfield|
                        if subfield.code == '6'
                            marc_match_suffix = subfield.value[subfield.value.index("-")..-1]
                        end
                    end

                    imprint[:value] = extractor.collect_subfields(field,spec).first

                    
                    if field.tag == "262"
                        imprint[:type] = "soundrecording"
                    elsif field.tag == "264"
                        case field.indicator2
                        when "1"
                            imprint[:type] = "publicaton"
                        when "0"
                            imprint[:type] = "production"
                        when "2"
                            imprint[:type] = "distribution"
                        when "3"
                            imprint[:type] = "manufacturer"
                        else
                            imprint[:type] = "publication"
                        end
                    else
                        imprint[:type] = "publication"
                    end

                    vernacular = vernacular_bag[field.tag + marc_match_suffix];
                    imprint[:vernacular] = vernacular if vernacular
                end

                acc << imprint if !imprint.empty?
            end
        end

        ################################################
        # Lambda for Authors
        ######
        def argot_authors(spec)
            lambda do |rec, acc|
                st = ArgotSemantics.get_authors(rec, spec)
                acc << st if st
            end
        end

        ################################################
        # Create a nested authors object
        ######
        def self.get_authors(rec, spec = "100")
             authors = {
                :director => []
            }

            vernacular_bag = ArgotSemantics.create_vernacular_bag(rec, spec)

            Traject::MarcExtractor.cached(spec, :alternate_script => false).each_matching_line(rec) do |field, spec, extractor|
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
                    :name => str
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
        # Lambda for Title
        ######
        def argot_title(spec)
            lambda do |rec, acc|
                is_journal = ArgotSemantics.is_journal(rec)
                st = ArgotSemantics.get_title(rec, spec, is_journal)
                acc << st if st
            end
        end

        ################################################
        # Create a nested title object
        ######
        def self.get_title(rec, spec = "245", is_journal = false)
            title_hash = {
                :sort => [],
                :main => [],
                :abbreviation => [],
                :translation => [],
                :uniform => [],
                :collective => [],
                :earlier => [],
                :later => [],
                :analytical => [],
                :alternate => [],
                :journal => [],
            }

            title_hash[:sort] << Marc21Semantics.get_sortable_title(rec)

            vernacular_bag = ArgotSemantics.create_vernacular_bag(rec, spec)

            Traject::MarcExtractor.cached(spec, :alternate_script => false).each_matching_line(rec) do |field, spec, extractor|
                str = extractor.collect_subfields(field, spec).first

                marc_match_suffix = ''

                field.subfields.each do |subfield|
                    if subfield.code == '6'
                        marc_match_suffix = subfield.value[subfield.value.index("-")..-1]
                    end
                end

                vernacular = vernacular_bag[field.tag + marc_match_suffix]

                case field.tag
                when "245"
                    key = "main";
                when "210"
                    key = "abbreviation"
                when "242"
                    key = "translation"
                when "240"
                    key = "uniform"
                when "130"
                    key = "uniform"
                when "243"
                    key = "collective"
                when "780"
                    key = "earlier"
                when "785"
                    key = "later"
                else
                    if field.tag.to_i > 700 && field.tag.to_i < 800 && field.indicator2 == "2"
                        key = "analytical"
                    else
                        key = "alternate"
                    end
                end

                title = {
                    :value => str
                }
                title[:vernacular] = vernacular if vernacular

                if is_journal && key == 'main'
                    title_hash[:journal] << title 
                end

                title_hash[key.to_sym] << title

            end

            #cleanup
            title_hash.each do |k,v|
                if v.empty?
                    title_hash.delete(k)
                end
            end

            title_hash
        end

        ################################################
        # Lambda for Notes
        ######
        def argot_notes(config)
            lambda do |rec, acc|
                st = {}
                config.each do |key, spec|
                    extractor = MarcExtractor.cached(spec, :separator => nil)
                    note = extractor.extract(rec)
                    st[key] = note if !note.empty?
                end

                acc << st if !st.empty?
            end
        end

        ################################################
        # Lambda for Linking
        ######
        def argot_linking_attributes(config)
            lambda do |rec, acc|
                st = {}
                config.each do |key, spec|
                    link = ArgotSemantics.get_linking_hash(rec, spec)
                    st[key] = link if link
                end
                acc << st if !st.empty?
            end
        end

        ################################################
        # Create a nested linking
        ######
        def self.get_linking_hash(rec, spec)
            linking_array = []

            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec, extractor|

                str = field.select { |subfield| subfield.code != 'x' or subfield.code != 'z' }
                isn = field.select { |subfield| subfield.code == 'x' or subfield.code == 'z' }


                link_hash = {
                    :value => str,
                    :isn => isn,
                }
                
                linking_array << link_hash
            end

            linking_array if !linking_array.empty?
        end

        ################################################
        # Lambda for Frequency
        ######
        def argot_frequency(config)
            lambda do |rec, acc|
                st = {}
                config.each do |key, spec|
                    extractor = MarcExtractor.cached(spec, :separator => nil)
                    frequency = extractor.extract(rec)
                    st[key] = frequency if !frequency.empty?
                end
                acc << st if !st.empty?
            end
        end

        ################################################
        # Lambda for Description
        ######
        def argot_description(config)
            lambda do |rec, acc|
                st = {}
                config.each do |key, spec|
                    extractor = MarcExtractor.cached(spec, :separator => nil)
                    frequency = extractor.extract(rec)
                    st[key] = frequency if !frequency.empty?
                end
                acc << st if !st.empty?
            end
        end

        ################################################
        # Lambda for Series
        ######
        def argot_series(config)
            lambda do |rec, acc|
                st = {}
                config.each do |key, spec|
                    series = ArgotSemantics.get_gvo(rec, spec)
                    st[key] = series if series
                end
                acc << st if !st.empty?
            end
        end     

        ################################################
        # Lambda for Generic Vernacular Object
        ######
        def argot_gvo(spec)
            lambda do |rec, acc|
                gvo = ArgotSemantics.get_gvo(rec, spec)
                acc << gvo if gvo
            end
        end

        ################################################
        # Get general vernarcular object
        ######

        def self.get_gvo(rec, spec)

            gvo = {}

            vernacular_bag = ArgotSemantics.create_vernacular_bag(rec, spec)

            Traject::MarcExtractor.cached(spec, :alternate_script => false).each_matching_line(rec) do |field, spec, extractor|

                str = extractor.collect_subfields(field,spec).first

                marc_match_suffix = ''

                field.subfields.each do |subfield|
                    if subfield.code == '6'
                        marc_match_suffix = subfield.value[subfield.value.index("-")..-1]
                    end
                end

                vernacular = vernacular_bag[field.tag + marc_match_suffix]

                gvo[:value] = str if str
                gvo[:vernacular] = vernacular if vernacular

            end

            gvo if !gvo.empty?
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
                            :value => str
                        }
                        vernacular_bag[marc_match][:lang_code] = lang if lang

                    end
                end
            end

            vernacular_bag
        end

        ################################################
        # Test if record is a journal or not
        ######
        def self.is_journal(rec)
            false
        end

    end
end
