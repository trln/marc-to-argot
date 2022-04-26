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
    # Lambda for Primary OCLC Number
    ######
    def argot_primary_oclc(config)
      lambda do |rec, acc|
        st = []
        field_035q = MarcExtractor.cached('035q')
        if !field_035q.extract(rec).include?('exclude')
          config.each do |key, spec|
            extractor = MarcExtractor.cached(spec, separator: nil)
            oclc_num = extractor.extract(rec).collect! do |o|
              Marc21Semantics.oclcnum_extract(o)
            end.compact 
            st << oclc_num.uniq

          end
          acc << st.flatten.first unless st.nil? || st.empty?
      end
    end
    end


    # ################################################
    # # Lambda for ISSN
    # ######
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
    
    # ################################################
    # # Lambda for Frequency
    # ######
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

  end
end
