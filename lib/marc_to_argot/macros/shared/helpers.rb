module MarcToArgot
  module Macros
    module Shared
      module Helpers

        ################################################################
        # general helpers
        ################################################################

        # tests whether at least one occurrence of field exists in record
        # @param record [MARC::Record] the record to check
        # @param field_tag [String] the tag of the field to check for
        def field_present?(record, field_tag)
          tags = record.tags
          tags.include?(field_tag)
        end
        
        # tests whether a field's subfields with a particular code
        # contain any instance of a substring
        # @param field [MARC::DataField] the field to check for a subfield substring
        # @param code [String] the code for the subfields to check
        # @param substring [String] the substring to test for presence
        def substring_present_in_subfield?(field, code, substring)
          subfield_values = collect_subfield_values_by_code(field, code)
          subfield_values.collect { |sy| sy.downcase.include?(substring) }.any?
        end

        # collects an array of values from all instances of a particular subfield
        # code from a field
        # @param field [MARC::DataField] the field to collect subfields from
        # @param code [String]|Array the code(s) of the subfield(s) to collect
        def collect_subfield_values_by_code(field, code)
          field.subfields.select { |sf| [*code].include?(sf.code) }.map(&:value)
        end

        # collects an array of values from all instances of one or more subfields
        # and joins those values with the specified separator
        # @param field [MARC::DataField] the field to collect subfields from
        # @param code [String]|[Array] the code(s) of the subfield to collect
        # @param separator [String] the string to use to join the values
        def collect_and_join_subfield_values(field, code, separator = ' ')
          field.subfields.select { |sf| [*code].include?(sf.code) }.map(&:value).join(separator)
        end

        def subfields_present(field)
          field.subfields.collect { |sf| sf.code }
        end

        def subfield_count_map(field)
          sfs = subfields_present(field)
          unique = sfs.uniq
          map = {}
          unique.each do |sfu|
            map[sfu] = sfs.count { |sfc| sfc == sfu }
          end

          map
        end

        def get_data_source_code(field)
          sfs = field.find_all { |sf| sf.code == '2' }
          return sfs[0].value.strip if sfs.any?
        end

        def capitalize_first_letter(value)
          value = value.split('')
          value.first.upcase! unless value.first.nil?
          value = value.join
          value
        end

        ################################################################
        # ID field-related helpers
        ################################################################

        # Takes a string and returns the identifier portion:
        # "123456" => "123456"
        # "123456 (abc)" => "123456"
        # "123456 abc" => "123456 abc"
        # "(123456)" => "(123456)"
        # "(123456) (abc)" => "(123456)"
        def extract_identifier(sf_value)
          identifier = split_identifier_and_qualifier(sf_value).first
          enclosed_id_match = /[\(\[]#{Regexp.escape(identifier.to_s)}[\)\]]/.match(sf_value)

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
          return clean_qualifier(qualifier[1]) if qualifier.length > 1
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

        def clean_qualifier(value)
          value.tr('[]();', '')
        end

        def gather_qualifiers(field, sfs_to_extract_quals_from, sfs_to_treat_as_quals)
          quals = []
          field.subfields.each do |sf|
            if sfs_to_extract_quals_from.include?(sf.code)
              q = extract_qualifier(sf.value)
              quals << q unless q == nil
            end
            if sfs_to_treat_as_quals.include?(sf.code)
              quals << clean_qualifier(sf.value)
            end
          end

          if quals.size > 0
            return quals.join('; ')
          else
            return nil
          end
        end

        def qualifier_extracted_or_q(field, sf)
          extracted_qualifier = extract_qualifier(sf.value)
          return extracted_qualifier if extracted_qualifier

          sf_q = field.subfields.select { |ssf| ssf.code == 'q' }
          return remove_parentheses(sf_q.first.value) if sf_q.any?
        end

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

        # Break up a MARC field with repeating id-bearing subfields
        # Allows determination of what qualifying info goes with what ID
        # PARAMETERS:
        # field (MARC::DataField) - the original MARC field
        # id_subfields (String) - subfield codes known to bear ID values
        # qual_subfields (String) - subfield codes where entire value is expected to be qualifying info
        # RETURNS:
        # Array of MARC::DataField objects, with only one id-bearing subfield each
        # Tag, indicators, and $2 from original field are carried over. 
        def split_complex_id_field(field, id_subfields, qual_subfields)
          split_fields = []
          fieldbuild = ''
          data_source_code = get_data_source_code(field)

          #check whether there are any id_subfields in the field.
          #if not, return an array containing just the original field
          sfp = subfields_present(field)

          if sfp.any? { |sf| id_subfields.include?(sf) }
            field.subfields.each do |sf|
              if id_subfields.include?(sf.code)
                fieldbuild = MARC::DataField.new(field.tag, field.indicator1, field.indicator2)
                split_fields << fieldbuild
                fieldbuild.subfields << sf
                if data_source_code
                  fieldbuild.subfields << MARC::Subfield.new('2', data_source_code)
                end
              elsif qual_subfields.include?(sf.code)
                fieldbuild.subfields << sf
              end
            end
            split_fields
          else
            [field]
          end
        end

        def field_tag_or_880_linkage_tag(field)
          if field.tag == '880'
            collect_subfield_values_by_code(field, '6').first[0..2]
          else
            field.tag
          end
        end
      end
    end
  end
end
