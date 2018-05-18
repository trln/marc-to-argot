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
          id_subfields = 'az'
          qual_subfields = 'q'

          split_fields = split_complex_id_field(field, id_subfields, qual_subfields)

          split_fields.each do |sfield|
            id_hash = assemble_id_hash(value_from_015(sfield, id_subfields),
                                       type: type_from_015(sfield),
                                       qual: gather_qualifiers(sfield, id_subfields, qual_subfields))
            ids << id_hash if id_hash.has_key?('value')
          end
          ids
        end

        def value_from_015(field, id_subfields)
          sfs = field.find_all { |sf| id_subfields.include?(sf.code) }
          extract_identifier(sfs[0].value) if sfs.any?
        end

        def type_from_015(field)
          source_code = get_data_source_code(field)
          if source_code
            type =  national_bibliography_codes[source_code] || 'National Bibliography Number'
          else
            type =  'National Bibliography Number'
          end

          type = "#{type} #{cancelled_type}" if subfields_present(field).include?('z')
          type
        end

        def national_bibliography_codes
          @national_bibliography_codes ||=Traject::TranslationMap.new('shared/national_bibliography_codes')
        end

        ################################################
        # MARC 024 Processor
        ######

        def misc_id_024(field)
          ids = []
          id_subfields = 'az'
          qual_subfields = 'dq'

          if field.indicator1 != '1'
            split_fields = split_complex_id_field(field, id_subfields, qual_subfields)

            split_fields.each do |sfield|
                id_hash = assemble_id_hash(value_from_024(sfield, id_subfields),
                                           type: type_from_024(sfield),
                                           qual: gather_qualifiers(sfield, id_subfields, qual_subfields))
                ids << id_hash if id_hash.has_key?('value')
            end
          end

          ids
        end

        def value_from_024(field, id_subfields)
          sfs = field.subfields.select { |sf| id_subfields.include?(sf.code) }
          extract_identifier(sfs[0].value) if sfs.any? 
        end

        def type_from_024(field)
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
            type = identifier_codes[get_data_source_code(field)] || 'Unspecified Standard Number'
          when '8'
            type = 'Unspecified Standard Number'
          end

          type = "#{type} #{cancelled_type}" if subfields_present(field).include?('z')
          type

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
                                       qual: gather_qualifiers(field, '', 'bq'),
                                       display: display_from_028(field))
            ids << id_hash if id_hash.has_key?('value')
          end

          ids
        end

        def value_from_028(field)
          field.subfields.select { |sf| sf.code == 'a' }.map(&:value).first
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
