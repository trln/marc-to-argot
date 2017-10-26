# Encoding: UTF-8

require 'marc_to_argot/call_numbers'
require 'traject/marc_extractor'

module Traject::Macros
  module ArgotSemantics
    include MarcToArgot::CallNumbers
    # shortcut
    MarcExtractor = Traject::MarcExtractor

    ################################################
    # Lambda for OCLC Number
    ######
    def argot_oclc_number(config)
      lambda do |rec, acc|
        st = {}
        config.each do |key, spec|
          extractor = MarcExtractor.cached(spec, separator: nil)
          oclc_num = extractor.extract(rec).collect! do |o|
            Marc21Semantics.oclcnum_extract(o)
          end.compact

          oclc_num = oclc_num.uniq

          if key == 'value'
            st[key] = oclc_num.first if oclc_num
          else
            st[key] = oclc_num unless oclc_num.empty?
          end
        end

        acc << st unless st.empty?
      end
    end

    ################################################
    # Lambda for Rollup ID
    ######
    def argot_rollup_id(spec)
      lambda do |rec, acc|
        extractor = MarcExtractor.cached(spec, separator: nil)
        oclc_num = extractor.extract(rec).collect! do |o|
          Marc21Semantics.oclcnum_extract(o)
        end.compact
        acc << "OCLC#{oclc_num.first}"
      end
    end

    ################################################
    # Lambda for ISSN
    ######
    def argot_issn(config)
      lambda do |rec, acc|
        st = {}
        config.each do |key, spec|
          extractor = MarcExtractor.cached(spec, separator: nil)
          issn = extractor.extract(rec).collect! do |o|
            StdNum::ISSN.normalize(o)
          end.compact

          st[key] = issn.uniq unless issn.empty?
        end

        acc << st unless st.empty?
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

        Traject::MarcExtractor.cached(spec, alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
          field.subfields.each do |subfield|
            if subfield.code == '6'
              marc_match_suffix = subfield.value[subfield.value.index('-')..-1]
              end

            next unless field.tag == '264'
            publisher[:name] = subfield.value if subfield.code == 'b'
          end

          unless publisher[:name]
            publisher[:name] = extractor.collect_subfields(field, spec).first
          end

          if field.tag == '264'
            case field.indicator2
            when '1'
              publisher[:type] = 'publisher'
            when '0'
              publisher[:type] = 'producer'
            when '2'
              publisher[:type] = 'distributor'
            when '3'
              publisher[:type] = 'manufacturer'
            else
              publisher = {}
              end
          else
            publisher[:type] = 'publisher'
          end

          vernacular = vernacular_bag[field.tag + marc_match_suffix]
          publisher[:vernacular] = vernacular if vernacular
        end

        acc << publisher unless publisher.empty?
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

        Traject::MarcExtractor.cached(spec, alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
          field.subfields.each do |subfield|
            if subfield.code == '6'
              marc_match_suffix = subfield.value[subfield.value.index('-')..-1]
              end
          end

          imprint[:value] = extractor.collect_subfields(field, spec).first

          imprint[:type] = if field.tag == '262'
                             'soundrecording'
                           elsif field.tag == '264'
                             case field.indicator2
                             when '1'
                               'publicaton'
                             when '0'
                               'production'
                             when '2'
                               'distribution'
                             when '3'
                               'manufacturer'
                             else
                               'publication'
                             end
                           else
                             'publication'
                           end

          vernacular = vernacular_bag[field.tag + marc_match_suffix]
          imprint[:vernacular] = vernacular if vernacular
        end

        acc << imprint unless imprint.empty?
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

    def argot_author_facet(spec)
      lambda do |rec, acc|
        authors = ArgotSemantics.get_author_facet(rec, spec)
        acc.concat authors if authors.any?
      end
    end

    def self.get_author_facet(rec, spec='100abcdgjqa')
      authors = []

      Traject::MarcExtractor.cached(spec, alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
        special_subfield_codes = field.subfields.select do |subfield|
          /^[gntke4]$/ =~ subfield.code
        end.map(&:code)

        if field.tag != '700' ||
          (field.tag == '700' &&
            (field.indicator2 == '2' ||
              (field.indicator2 != '2' &&
                (subfield_tk_absent(special_subfield_codes) &&
                  (subfield_e4_absent(special_subfield_codes) ||
                   e4_maps_to_creator(field) ||
                   has_allowable_e4_value(field))))))

          allowable_subfields = field.subfields.select do |subfield|
            spec.includes_subfield_code?(subfield.code)
          end

          # Remove gn subfields if occurs after t or k
          %w(g n).each { |code| remove_subfield_after_tk(allowable_subfields, special_subfield_codes, code) }

          # Join the values of each subfield.
          author = allowable_subfields.map(&:value).join(' ') if allowable_subfields.any?

          # Trim punctation from the string of joined subfields
          author = Traject::Macros::Marc21.trim_punctuation(author) unless author.nil? || author.empty?

          # Accumulate author string in array if present
          authors << author unless author.nil? || author.empty?
        end
      end

      authors
    end

    def self.relator_categories
      @relator_categories ||= Traject::TranslationMap.new('shared/relator_categories')
    end

    def self.subfield_tk_absent(codes)
      codes.select { |i| /^[tk]$/ =~ i }.empty?
    end

    def self.subfield_e4_absent(codes)
      codes.select { |i| /^[e4]$/ =~ i }.empty?
    end

    def self.has_allowable_e4_value(field)
      has_allowable_e_value(field) || has_allowable_4_value(field)
    end

    def self.has_allowable_e_value(field)
      field.subfields.select do |sf|
        sf.code == 'e' && sf.value =~ /^(editor|editor of compilation|director|film director)$/
      end.any?
    end

    def self.has_allowable_4_value(field)
      field.subfields.select do |sf|
        sf.code == '4' && sf.value =~ /^(edt|edc|drt|fmd)$/
      end.any?
    end

    def self.e4_maps_to_creator(field)
      field.subfields.select do |sf|
        sf.code =~ /^(e|4)$/ && relator_categories[sf.value] == 'creator'
      end.any?
    end

    def self.subfield_before_t_and_k(subfield, codes)
      if codes.include?('t') && codes.include?('k')
        codes.index(subfield) < codes.index('t') && codes.index(subfield) < codes.index('k')
      elsif codes.include?('t')
        codes.index(subfield) < codes.index('t')
      elsif codes.include?('k')
        codes.index(subfield) < codes.index('k')
      end
    end

    def self.remove_subfield_after_tk(subfields, special_subfield_codes, code)
      unless special_subfield_codes.include?(code) &&
         (subfield_tk_absent(special_subfield_codes) ||
         subfield_before_t_and_k(code, special_subfield_codes))
        subfields.delete_if { |sf| sf.code == code }
      end
    end

    ################################################
    # Create a nested authors object
    ######
    def self.get_authors(rec, spec = '100')
      authors = {
        director: []
      }

      vernacular_bag = ArgotSemantics.create_vernacular_bag(rec, spec)

      Traject::MarcExtractor.cached(spec, alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
        str = extractor.collect_subfields(field, spec).first

        marc_match_suffix = ''
        has_director = false

        field.subfields.each do |subfield|
          if subfield.code == '6'
            marc_match_suffix = subfield.value[subfield.value.index('-')..-1]
          end
          has_director = true if subfield.code == '4' && subfield.value == 'drt'
        end

        author_hash = {
          name: str
        }
        vernacular = vernacular_bag[field.tag + marc_match_suffix]
        author_hash[:vernacular] = vernacular if vernacular

        key = if field.tag.to_i < 700
                'main'
              elsif field.tag == '720'
                'uncontrolled'
              else
                'other'
              end

        authors[:director] << author_hash if has_director

        authors[key] = [] unless authors.key?(key)
        authors[key] << author_hash
      end

      # cleanup
      authors.each do |k, v|
        authors.delete(k) if v.empty?
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
    def self.get_title(rec, spec = '245', is_journal = false)
      title_hash = {
        sort: [],
        main: [],
        abbreviation: [],
        translation: [],
        uniform: [],
        collective: [],
        earlier: [],
        later: [],
        analytical: [],
        alternate: [],
        journal: []
      }

      title_hash[:sort] << Marc21Semantics.get_sortable_title(rec)

      vernacular_bag = ArgotSemantics.create_vernacular_bag(rec, spec)

      Traject::MarcExtractor.cached(spec, alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
        str = extractor.collect_subfields(field, spec).first

        marc_match_suffix = ''

        field.subfields.each do |subfield|
          if subfield.code == '6'
            marc_match_suffix = subfield.value[subfield.value.index('-')..-1]
          end
        end

        vernacular = vernacular_bag[field.tag + marc_match_suffix]

        case field.tag
        when '245'
          key = 'main'
        when '210'
          key = 'abbreviation'
        when '242'
          key = 'translation'
        when '240'
          key = 'uniform'
        when '130'
          key = 'uniform'
        when '243'
          key = 'collective'
        when '780'
          key = 'earlier'
        when '785'
          key = 'later'
        else
          key = if field.tag.to_i > 700 && field.tag.to_i < 800 && field.indicator2 == '2'
                  'analytical'
                else
                  'alternate'
                end
        end

        title = {
          value: str
        }
        title[:vernacular] = vernacular if vernacular

        title_hash[:journal] << title if is_journal && key == 'main'

        title_hash[key.to_sym] << title
      end

      # cleanup
      title_hash.each do |k, v|
        title_hash.delete(k) if v.empty?
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
          extractor = MarcExtractor.cached(spec, separator: nil)
          note = extractor.extract(rec)
          st[key] = note unless note.empty?
        end

        acc << st unless st.empty?
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
        acc << st unless st.empty?
      end
    end

    ################################################
    # Create a nested linking
    ######
    def self.get_linking_hash(rec, spec)
      linking_array = []

      Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, _spec, _extractor|
        str = field.select { |subfield| subfield.code != 'x' || subfield.code != 'z' }
        isn = field.select { |subfield| subfield.code == 'x' || subfield.code == 'z' }

        link_hash = {
          value: str,
          isn: isn
        }

        linking_array << link_hash
      end

      linking_array unless linking_array.empty?
    end

    ################################################
    # Lambda for Frequency
    ######
    def argot_frequency(config)
      lambda do |rec, acc|
        st = {}
        config.each do |key, spec|
          extractor = MarcExtractor.cached(spec, separator: nil)
          frequency = extractor.extract(rec)
          st[key] = frequency unless frequency.empty?
        end
        acc << st unless st.empty?
      end
    end

    ################################################
    # Lambda for Description
    ######
    def argot_description(config)
      lambda do |rec, acc|
        st = {}
        config.each do |key, spec|
          extractor = MarcExtractor.cached(spec, separator: nil)
          description = extractor.extract(rec)
          st[key] = description unless description.empty?
        end
        acc << st unless st.empty?
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
        acc << st unless st.empty?
      end
    end

    ################################################
    # Lambda for Subjects
    ######

    def argot_subjects(options={})
      spec            = options[:spec] || '600|*0|abcdfghjklmnopqrstu'
      subd_separator  = options[:subdivison_separator] || ' '
      classifications = options[:classifications] || nil
      filter_method   = options[:filter_method] || nil

      lambda do |rec, acc|
        acc.concat ArgotSemantics.subject_extractor(rec,
                                                    spec,
                                                    subd_separator,
                                                    classifications,
                                                    filter_method)
      end
    end

    def self.subject_extractor(rec, spec, separator, classifications=nil, filter=nil)
      subjects = []
      Traject::MarcExtractor.cached(spec, alternate_script: false, separator: separator).each_matching_line(rec) do |field, spec, extractor|
        if classifications.nil? || subfield_2_classification_constraint(field, classifications)
          subfields = collect_subject_subfields(field, spec, separator, filter)
          subjects.concat(subfields)
        end
      end
      subjects.uniq
    end

    def self.collect_subject_subfields(field, spec, separator, filter)
      subfields = field.subfields.collect do |subfield|
        subfield_value = subfield.value if spec.includes_subfield_code?(subfield.code)
        subfield_value = method(filter).call(subfield) if filter && subfield_value
        Traject::Macros::Marc21.trim_punctuation(subfield_value)
      end.compact

      return subfields if subfields.empty?

      if separator && spec.joinable?
        subfields = [subfields.join(separator)]
      end

      subfields
    end

    def self.subfield_2_classification_constraint(field, classifications)
      class_scheme = field.subfields.select { |subfield| subfield.code == '2' }.first
      class_scheme && class_scheme.value =~ classifications
    end

    def self.strip_provenance(subfield)
      if subfield.code == 'a'
        subfield.value.gsub(' (Provenance)', '')
      else
        subfield.value
      end
    end

    def argot_genre_special_cases(options={})
      spec        = options[:spec] || '008[33]:008[34]'
      mapped_byte = options[:mapped_byte] || 33
      bio_byte    = options[:bio_byte] || 34
      constraint  = options[:constraint] || nil

      lambda do |rec, acc|

        Traject::MarcExtractor.cached(spec, alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
          if rec.leader.byteslice(6) =~ /[a]/ && rec.leader.byteslice(7) =~ /[acdm]/
            if constraint.nil? || ArgotSemantics.method(constraint).call(field)
              field_value = field.value.byteslice(spec.bytes)
              mapped_values = []
              if spec.bytes == mapped_byte
                mapped_values << case field_value
                                 when '0'
                                   'Nonfiction'
                                 when '1'
                                   'Fiction'
                                 when 'd'
                                   'Drama'
                                 when 'e'
                                   'Essays'
                                 when 'f'
                                   'Novels'
                                 when 'h'
                                   'Humor, satire, etc'
                                 when 'i'
                                   'Letters'
                                 when 'j'
                                   'Short stories'
                                 when 'p'
                                   'Poetry'
                                 when 's'
                                   'Speeches, addresses, etc'
                                 end
              end

              if spec.bytes == bio_byte
                mapped_values << 'Biography' if field_value =~ /[abcd]/
              end
              acc.concat mapped_values unless mapped_values.empty?
            end
          end
        end
      end
    end

    def self.field_006_byte_00_at(field)
      field.value.byteslice(0) =~ /[at]/
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

      Traject::MarcExtractor.cached(spec, alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
        str = extractor.collect_subfields(field, spec).first

        marc_match_suffix = ''

        field.subfields.each do |subfield|
          if subfield.code == '6'
            marc_match_suffix = subfield.value[subfield.value.index('-')..-1]
          end
        end

        vernacular = vernacular_bag[field.tag + marc_match_suffix]

        gvo[:value] = str if str
        gvo[:vernacular] = vernacular if vernacular
      end

      gvo unless gvo.empty?
    end

    ################################################
    # Create a bag of vernacular strings to pair with other marc fields
    ######
    def self.create_vernacular_bag(record, extract_fields)
      vernacular_bag = {}

      Traject::MarcExtractor.cached(extract_fields, alternate_script: :only).collect_matching_lines(record) do |field, spec, extractor|
        str = extractor.collect_subfields(field, spec).first

        field.subfields.each do |subfield|
          next unless subfield.code == '6'
          index_of_slash = subfield.value.rindex('/')
          lang_code = subfield.value[index_of_slash + 1..-1] if index_of_slash
          marc_match = subfield.value[0..index_of_slash - 1] if index_of_slash

          case lang_code
          when '(3'
            lang = 'ara'
          when '(B'
            lang = 'lat'
          when '$1'
            lang = 'cjk'
          when '(N'
            lang = 'rus'
          when '(S'
            lang = 'gre'
          when '(2'
            lang = 'heb'
          end

          vernacular_bag[marc_match] = {
            value: str
          }
          vernacular_bag[marc_match][:lang_code] = lang if lang
        end
      end

      vernacular_bag
    end

    ################################################
    # Test if record is a journal or not
    ######
    def self.is_journal(_rec)
      false
    end

    #####
    # Converts an array of string to a delimited hierarchical facet
    # value as expected by blacklight-hierarchy.
    # e.g. [foo, bar, baz] => [ foo, foo:bar, foo:bar:baz ]
    def array_to_hierarchy_facet(args, delimiter = ':')
      result = []
      args.each_with_object([]) do |part, acc|
       acc << part
       result << acc.join(delimiter)
      end
      result
    end

    def arrays_to_hierarchy(values)
      values.collect { |v| array_to_hierarchy_facet(v) }.flatten!.uniq
    end


    # extracts call numbers from an items
    # and maps them into the output_hash
    # populates: `call_number_schemes`,
    # `normalized_call_numbers`,
    # and `lcc_callnum_classification`
    def map_call_numbers(ctx, items)
      call_numbers = items.each_with_object({}) do |i, cns|
        scheme = i['cn_scheme']
        next unless %w[LC SUDOC].include?(scheme)
        numbers = (cns[scheme] ||= [])
        numbers << if scheme == 'LC'
                     LCC.normalize(i['call_no'])
                   else
                     i['call_no']
                   end
      end
      ctx.output_hash['call_number_schemes'] = call_numbers.keys
      ctx.output_hash['normalized_call_numbers'] = call_numbers.collect do |scheme, values|
        s = scheme.downcase
        values.collect { |v| "#{s}:#{v}" }
      end.flatten.uniq

      return unless call_numbers.key?('LC')
      res = []
      LCC.find_path(call_numbers['LC'].first).each_with_object([]) do |part, acc|
        acc << part
        res << acc.join(':')
      end
      ctx.output_hash['lcc_callnum_classification'] = res
    end

    # maps languages, by default out of 008[35-37] and 041a and 041d
    #
    # de-dups values so you don't get the same one twice.
    #
    # Note: major issue with legacy marc records
    #   Legacy records would jam all langs into 041 indicator1
    #   E.g., an material translated from latin -> french -> english, would have all
    #   3 languages in 041a, though the material may not have any french text
    #
    #   To remedy, any 041a indicator 1, with a value of 6 or more
    #   alpha characters will be thrown out

    def argot_languages(spec = "008[35-37]:041")
      translation_map = Traject::TranslationMap.new("marc_languages")

      extractor = MarcExtractor.new(spec, :separator => nil)

      lambda do |record, accumulator|
        codes = extractor.collect_matching_lines(record) do |field, spec, extractor|
          if extractor.control_field?(field)
            (spec.bytes ? field.value.byteslice(spec.bytes) : field.value)
          else
            # the following 2 lines are used to skip legacy records with
            # potential dirty data, see note above
            subfield_a = field.subfields.find { |subfield| subfield.code == 'a' }
            check_subfield_a = subfield_a.nil? ? '' : subfield_a.value
            next if field.tag == '041' && field.indicator1 == '1' && check_subfield_a.length > 6
            extractor.collect_subfields(field, spec).collect do |value|
              # sometimes multiple language codes are jammed together in one subfield, and
              # we need to separate ourselves. sigh.
              unless value.length == 3
                # split into an array of 3-length substrs; JRuby has problems with regexes
                # across threads, which is why we don't use String#scan here.
                value = value.chars.each_slice(3).map(&:join)
              end
              value
            end.flatten
          end
        end
        codes = codes.uniq

        translation_map.translate_array!(codes)

        accumulator.concat codes
      end
    end
  end
end
