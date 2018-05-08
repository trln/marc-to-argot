module MarcToArgot
  module Macros
    module Shared
      module MiscId
        ################################################
        # Misc ID
        ######

        def misc_id
          lambda do |rec, acc|
            Traject::MarcExtractor.cached('010abz:015a:024adz:027az:028a:030az:074az:088az')
                                  .each_matching_line(rec) do |field, spec, extractor|
              case field.tag
              when '010'
                acc.concat misc_id_010(field)
              when '015'
                acc.concat misc_id_015(field)
              when '024'
                acc.concat misc_id_024(field)
              when '027'
                acc.concat misc_id_027(field)
              when '028'
                acc.concat misc_id_028(field)
              when '030'
                acc.concat misc_id_030(field)
              when '074'
                acc.concat misc_id_074(field)
              when '088'
                acc.concat misc_id_088(field)
              end
            end
            acc.uniq!
          end
        end

        ################################################
        # Misc ID Helpers
        ######

        def assemble_id_hash(value, options = {})
          id = {}

          type = options.fetch(:type, nil)
          qual = options.fetch(:qual, nil)
          display = options.fetch(:display, nil)

          id['value'] = value unless value.nil? || value.empty?
          id['type'] = type unless type.nil? || type.empty? || display == 'false'
          id['qual'] = qual unless qual.nil? || qual.empty? || display == 'false'
          id['display'] = display unless display.nil? || display.empty?

          id
        end

        # Takes a string and returns the identifier portion:
        # "123456" => "123456"
        # "123456 (abc)" => "123456"
        # "123456 abc" => "123456 abc"
        # "(123456)" => "(123456)"
        # "(123456) (abc)" => "(123456)"
        def extract_identifier(sf_value)
          identifier = split_identifier_and_qualifier(sf_value).first
          enclosed_id_match = /[\(\[]#{Regexp.escape(identifier)}[\)\]]/.match(sf_value)

          enclosed_id_match ? enclosed_id_match[0] : identifier
        end

        # Takes a string and returns the qualifier portion
        #   with parentheses and brackets removed:
        # "123456" => nil
        # "123456 (abc)" => "abc"
        # "123456 abc" => nil
        # "(123456)" => nil
        # "(123456) (abc)" => "abc"
        def extract_qualifier(sf_value)
          qualifier = split_identifier_and_qualifier(sf_value)
          return qualifier[1] if qualifier.length > 1
        end

        # Takes a string and returns an array of
        #   the identifier and qualifier components.
        #   the first item is always the identifier.
        #   any outer brackets or parentheses present in the
        #   identifier get reconstitued by #extract_identifier.
        # "123456" => ["123456"]
        # "123456 (abc)" => ["123456", "abc"]
        # "123456 abc" => ["123456 abc"]
        # "(123456)" => ["123456"]
        # "(123456) (abc)" => ["123456", "abc"]
        def split_identifier_and_qualifier(sf_value)
          sf_value.split(/[\(\)\[\]]/).map(&:strip).delete_if { |str| str.empty? }
        end

        def remove_parentheses(value)
          value.tr('[]()', '')
        end

        def qualifier_extracted_or_q(field, sf)
          extracted_qualifier = extract_qualifier(sf.value)
          return extracted_qualifier if extracted_qualifier

          sf_q = field.subfields.select { |ssf| ssf.code == 'q' }
          return remove_parentheses(sf_q.first.value) if sf_q.any?
        end

        def type_a_or_z(sf, type)
          case sf.code
          when 'a'
            type
          when 'z'
            "#{type} #{cancelled_type}"
          end
        end

        def cancelled_type
          '(canceled or invalid)'
        end

        ################################################
        # MARC 010 Processor
        ######

        def misc_id_010(field)
          ids = []
          field.subfields.each do |sf|
            id_hash = assemble_id_hash(value_from_010_sf(sf), type: type_from_010_sf(sf))
            ids << id_hash if id_hash.has_key?('value')
          end

          ids
        end

        def value_from_010_sf(subfield)
          subfield.value.strip if %[a b z].include?(subfield.code)
        end

        def type_from_010_sf(subfield)
          case subfield.code
          when 'a'
            'LCCN'
          when 'b'
            'NUCMC'
          when 'z'
            "LCCN #{cancelled_type}"
          end
        end

        ################################################
        # MARC 015 Processor
        ######

        def misc_id_015(field)
          ids = []
          field.subfields.each do |sf|
            id_hash = assemble_id_hash(value_from_015_sf(sf),
                                       type: type_from_015(field),
                                       qual: qualifier_extracted_or_q(field, sf))
            ids << id_hash if id_hash.has_key?('value')
          end

          ids
        end

        def value_from_015_sf(sf)
          extract_identifier(sf.value) if sf.code == 'a'
        end

        def type_from_015(field)
          sf_2 = field.subfields.select { |ssf| ssf.code == '2' }
          sf_2_code = sf_2.first.value if sf_2.any?

          national_bibliography_codes[sf_2_code] || 'National Bibliography Number'
        end

        def national_bibliography_codes
          @national_bibliography_codes ||=Traject::TranslationMap.new('shared/national_bibliography_codes')
        end

        ################################################
        # MARC 024 Processor
        ######

        def misc_id_024(field)
          ids = []
          field.subfields.each do |sf|
            id_hash = assemble_id_hash(value_from_024_sf(field, sf),
                                       type: type_from_024_sf(field, sf),
                                       qual: qualifier_extracted_or_q(field, sf))
            ids << id_hash if id_hash.has_key?('value')
          end

          ids
        end

        def value_from_024_sf(field, sf)
          value = extract_identifier(sf.value)
          case sf.code
          when 'a'
            sf_d = field.subfields.select { |ssf| ssf.code == 'd' }
            sf_d_value = sf_d.first.value if sf_d.any?
            [value, sf_d_value].compact.join(' ')
          when 'z'
            value
          end
        end

        def type_from_024_sf(field, sf)
          case field.indicator1
          when '0'
            type = 'International Standard Recording Number'
          when '2'
            type = 'International Standard Music Number'
          when '3'
            type = 'International Standard Article Number'
          when '4'
            type = 'Serial Item and Contribution Identifier'
          when '7'
            sf_2 = field.subfields.select { |ssf| ssf.code == '2' }
            sf_2_code = sf_2.first.value if sf_2.any?
            type = identifier_codes[sf_2_code] || 'Unspecified Standard Number'
          when '8'
            type = 'Unspecified Standard Number'
          end

          sf.code == 'z' ? "#{type} #{cancelled_type}" : type
        end

        def identifier_codes
          @identifier_codes ||= Traject::TranslationMap.new('shared/identifier_codes')
        end

        ################################################
        # MARC 027 Processor
        ######

        def misc_id_027(field)
          ids = []
          field.subfields.each do |sf|
            id_hash = assemble_id_hash(sf.value.strip,
                                       type: type_a_or_z(sf, 'Technical Report Number'))
            ids << id_hash if id_hash.has_key?('value')
          end

          ids
        end

        ################################################
        # MARC 028 Processor
        ######

        def misc_id_028(field)
          ids = []
          field.subfields.each do |sf|
            id_hash = assemble_id_hash(value_from_028(field),
                                       type: type_from_028(field),
                                       qual: qual_from_028(field),
                                       display: display_from_028(field))
            ids << id_hash if id_hash.has_key?('value')
          end

          ids
        end

        def value_from_028(field)
          field.select { |sf| sf.code == 'a' }.first.value
        end

        def qual_from_028(field)
          field.select { |sf| %w[b q].include?(sf.code) }
               .map { |sf| remove_parentheses(sf.value.strip) }
               .join("; ")
        end

        def display_from_028(field)
          'false' if %w[0 3].include?(field.indicator2)
        end

        def type_from_028(field)
          case field.indicator1
          when '0'
           'Issue Number'
          when '1'
           'Matrix Number'
          when '2'
           'Plate Number'
          when '3'
           'Music Publisher Number'
          when '4'
           'Video Publisher Number'
          when '5'
           'Publisher Number'
          when '6'
           'Distributor Number'
          end
        end

        ################################################
        # MARC 030 Processor
        ######

        def misc_id_030(field)
          ids = []
          field.subfields.each do |sf|
            id_hash = assemble_id_hash(sf.value.strip,
                                       type: type_a_or_z(sf, 'CODEN designation'))
            ids << id_hash if id_hash.has_key?('value')
          end

          ids
        end

        ################################################
        # MARC 074 Processor
        ######

        def misc_id_074(field)
          ids = []
          field.subfields.each do |sf|
            id_hash = assemble_id_hash(extract_identifier(sf.value),
                                       type: type_a_or_z(sf, 'GPO Item Number'),
                                       qual: qual_from_074_sf(sf))
            ids << id_hash if id_hash.has_key?('value')
          end

          ids
        end

        def qual_from_074_sf(subfield)
          qual = extract_qualifier(subfield.value)
          qual == 'MF' ? 'microfiche' : qual
        end

        ################################################
        # MARC 088 Processor
        ######

        def misc_id_088(field)
         ids = []
          field.subfields.each do |sf|
            id_hash = assemble_id_hash(sf.value.strip,
                                       type: type_a_or_z(sf, 'Report Number'))
            ids << id_hash if id_hash.has_key?('value')
          end

          ids
        end
      end
    end
  end
end
