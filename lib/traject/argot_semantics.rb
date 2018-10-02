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
        val = st['value']

        acc << st unless val.nil? || val.empty?
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
          issn = extractor.extract(rec).compact
          st[key] = issn.uniq unless issn.empty?
        end

        acc << st unless st.empty?
      end
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

    def argot_note_toc(config)
      lambda do |rec, acc|
        note_array = []
        Traject::MarcExtractor.cached(config).each_matching_line(rec) do |field, spec, extractor|
          keep_sfs = field.subfields.select {|sf| sf.code =~ /[agrt]/ }
          note_text = keep_sfs.map {|sf| sf.value.strip}
          case field.indicator1
          when '1'
            note_text.unshift('Incomplete contents:')
          when '2'
            note_text.unshift('Partial contents:')
          end
          note_array << note_text.join(' ') unless note_text.empty?
        end
        note_array.each {|e| acc << e} unless note_array.empty?
      end
    end

    def argot_note_summary(config)
      lambda do |rec, acc|
        note_array = []
        Traject::MarcExtractor.cached(config).each_matching_line(rec) do |field, spec, extractor|
          # material_specified is grabbed separately and added to beginning of field
          #  after any field type label is set using indicators
          material_specified = ''
          note_text = []
          field.subfields.each do |sf|
            value = sf.value.strip
            if sf.code =~ /[ab]/
              value.gsub!(/^Summary: /i, '')
              value.gsub!(/--$/, '')
              note_text << value
            elsif sf.code == 'c'
              value = "--#{value}"
              note_text << value
            elsif sf.code == '3'
              value.gsub!(/:$/, '')
              value = "(#{value}):"
              material_specified = value
            end
          end
          
          case field.indicator1
          when '1'
            note_text.unshift('Review:')
          when '2'
            note_text.unshift('Scope and content:')
          when '3'
            note_text.unshift('Abstract:')
          when '4'
            note_text.unshift('Content advice:')
          end

          note_text.unshift(material_specified) if material_specified.length > 0
          note_array << note_text.join(' ') unless note_text.empty?
        end
        note_array.each { |e| acc << e } unless note_array.empty?
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
          extractor = MarcExtractor.cached(spec)
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
      values.collect { |v| array_to_hierarchy_facet(v) }.flatten.uniq
    end

    # Converts array of strings representing a hierarchical values
    #  to delimited hierarchical facet values as expected by
    #  blacklight-hierarchy
    #  ['a:b:c', 'a:b:d'] => ['a', 'a:b', 'a:b:c', 'a:b:d']
    def explode_hierarchical_strings(array_of_strings, delimiter = ':')
      split_arrays = array_of_strings.map { |s| s.split(delimiter) }
      result = arrays_to_hierarchy(split_arrays)
      result.flatten.uniq
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

  def argot_languages(spec = "008[35-37]:041adeg")
    translation_map = Traject::TranslationMap.new("marc_languages")

    extractor = MarcExtractor.new(spec, :separator => nil)

    lambda do |record, accumulator|
      codes = extractor.collect_matching_lines(record) do |field, spec, extractor|
        if extractor.control_field?(field)
          (spec.bytes ? field.value.byteslice(spec.bytes) : field.value)
        else
          #get all potentially usable subfields
          subfields = field.subfields.collect do |sf|
            sf if spec.includes_subfield_code?(sf.code)
          end.compact
          #reject $a of translations with multiple languages crammed into $a
          good_subfields = subfields.reject { |sf| field.indicator1 == '1' && sf.code == 'a' && sf.value.length >=6 }
          good_subfields.collect do |sf|
            unless sf.value.length == 3
              value = sf.value.chars.each_slice(3).map(&:join)
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
