module MarcToArgot
  module Macros
    module Shared
      module OriginPlace

        def origin_place_facet
          lambda do |rec, acc|
            places = get_facetable_places(rec)
            acc.concat places if places
          end
        end

        def origin_place_search
          lambda do |rec, acc|
            places = get_searchable_places(rec)
            acc.concat places if places
          end
        end

        def get_facetable_places(rec)
          places = []
          places << get_facetable_752s(rec) if rec.tags.include?('752')
          places.flatten.uniq
        end

        def get_searchable_places(rec)
          places = []
          places << get_searchable_752s(rec)
          places << get_subfield_a_from_260_264_257(rec)
          places << map_country_code_in_008(rec)
          places << map_country_code_in_044(rec)
          places << published_in_united_states(rec)
          places.flatten.compact.reject(&:empty?).uniq
        end

        def get_facetable_752s(rec)
          all_places = []
          get_and_clean_752s(rec).each do |field|
            field.subfields.each do |sf|
              sf.value = 'New York (State)' if sf.code == 'b' && sf.value == 'New York'
              sf.value = 'New York County (N.Y.)' if sf.code == 'c' && sf.value == 'New York'
              sf.value = 'New York (N.Y.)' if sf.code == 'd' && sf.value == 'New York'
            end

            places = field.subfields.map{ |sf| sf.value }

            if field.to_s =~ /\$b District of Columbia \$[cd] Washington\.?/
              places.reject! { |v| v =~ /^Washington\.?/ }
              places << 'Washington (D.C.)'
            end
            all_places << places
          end
          all_places.flatten.uniq
        end

        def get_searchable_752s(rec)
          return unless rec.tags.include?('752')
          places = []
          get_and_clean_752s(rec).each do |field|
            place = {}
            place['value'] = field.subfields.map { |sf| sf.value }.join('--')
            lang = Vernacular::ScriptClassifier.new(field, place['value']).classify
            place['lang'] = lang unless lang.nil? || lang.empty?
            places << place
          end
          places
        end

        def map_country_code_in_008(rec)
          return unless rec.tags.include?('008')
          rec.fields('008').map do |field|
            code = (field.value.byteslice(15..17) || '').scrub(' ').gsub(/[^a-z]/, '')
            value = countries_marc[code]
            { 'value' => value  } unless value.nil? || value.empty? || code == 'xx'
          end
        end

        def map_country_code_in_044(rec)
          places = []
          Traject::MarcExtractor.cached('044a').each_matching_line(rec) do |field, spec, extractor|
            sfs = extractor.collect_subfields(field, spec)
            sfs.each do |sf|
              place = {}
              place['value'] = countries_marc[sf.to_s.strip]
              next if place['value'].nil? || place['value'].empty? || sf.to_s.strip == 'xx'
              places << place
            end
          end
          places
        end

        def published_in_united_states(rec)
          return unless rec.tags.include?('008') && rec.fields('008')
                                                       .first
                                                       .value
                                                       .byteslice(17) == 'u'
          { 'value' => 'United States' }
        end

        def countries_marc
           @countries_marc ||= Traject::TranslationMap.new('shared/countries_marc')
        end

        def get_subfield_a_from_260_264_257(rec)
          places = []
          Traject::MarcExtractor.cached('260a:264a:257a').each_matching_line(rec) do |field, spec, extractor|
            sfs = extractor.collect_subfields(field, spec)
            sfs.each do |sf|
              place = {}
              place['value'] = sf.to_s.strip.gsub(/\s[:;]$/, '')
              next if place['value'].nil? || place['value'].empty? || place['value'] == '[S.l.]' || place['value'].match(/n\.p\./i)
              lang = Vernacular::ScriptClassifier.new(field, place['value']).classify
              place['lang'] = lang unless lang.nil? || lang.empty?
              places << place
            end
          end
          places
        end

        def get_and_clean_752s(rec)
          places = []
          the752s = rec.fields.select { |f| f.tag == '752' }
          Traject::MarcExtractor.cached('752').each_matching_line(rec) do |field, spec, extractor|
            new_field = MARC::DataField.new('752', ' ', ' ')
            keep_sfs = %w[a b c d f g h]
            sfs = field.subfields.map { |sf| sf if keep_sfs.include?(sf.code)}.compact
            sfs.each { |sf| sf.value = sf.value.strip.gsub(/ +/, ' ') }
            sfs.each { |sf| sf.value = sf.value.gsub(/\.$/, '') }
            sfs.each { |sf| new_field.append(sf) }
            places << new_field
          end
          places
        end
      end
    end
  end
end

