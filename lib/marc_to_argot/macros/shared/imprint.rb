module MarcToArgot
  module Macros
    module Shared
      module Imprint

        ################################################################
        # imprint macros
        ################################################################

        # accumulates an array of JSON blobs with main imprint data from a record.
        def imprint_main
          lambda do |rec, acc|
            imprint_fields = []

            Traject::MarcExtractor.cached("260:264", alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
              imprint_fields << field
            end

            main_imprint = select_main_imprint(imprint_fields)

            acc << assemble_imprint_hash(main_imprint).to_json if main_imprint
          end
        end

        # accumulates an array of JSON blobs with all imprint data from a record
        # (but only if more than 1).
        def imprint_multiple
          lambda do |rec, acc|
            imprint_fields = []

            Traject::MarcExtractor.cached("260:264", alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
              imprint_fields << field
            end

            if imprint_fields.length > 1
              imprint_fields.each do |field|
                acc << assemble_imprint_hash(field).to_json
              end
            end
          end
        end

        # assembles a hash of imprint data to serialize
        # @param field [MARC::DataField] the field from which to extract imprints
        def assemble_imprint_hash(field)
          imprint_hash = {}
          imprint_hash[:type] = imprint_type(field)
          imprint_hash[:label] = imprint_label(field)
          imprint_hash[:value] = imprint_value(field)

          imprint_hash.delete_if { |k, v| v.nil? || v.empty? }
        end

        # sets the imprint type based on field tag and/or 2nd indicator value
        # @param field [MARC::DataField] the field to use to determine imprint type
        def imprint_type(field)
          if field.tag == '260'
            'imprint'
          elsif field.tag == '264'
            case field.indicator2
            when '0'
              'production'
            when '1'
              'publication'
            when '2'
              'distribution'
            when '3'
              'manufacture'
            when '4'
              'copyright'
            end
          end
        end

        # sets the imprint label based on the value of subfield 3
        # @param field [MARC::DataField] the field to use to determine imprint label
        def imprint_label(field)
          label_subfields = field.subfields.select { |sf| sf.value if sf.code == '3' }
          label_subfields.compact.map { |sf| sf.value.strip }.join(' ').gsub(/[,;:.]*$/, '').strip
        end

        # sets the imprint value from specific subfields
        # @param field [MARC::DataField] the field to use to determine imprint value
        def imprint_value(field)
          imprint_subfields = field.subfields.select { |sf| sf.value if sf.code =~ /[abcefg]/ }
          imprint_subfields.compact.map { |sf| sf.value.strip }.join(' ').strip
        end

        # selects main imprint field from a list of fields
        # @param fields [MARC::DataField] the fields from which to select the main imprint
        def select_main_imprint(fields)
          if fields.length == 1
            fields.first
          elsif all_260s?(fields)
            preferred_260(fields)
          elsif all_264s?(fields)
            preferred_264(fields)
          else
            fields.last
          end
        end

        # selects the preferred 260 field to use as the main imprint
        # @param fields [MARC::DataField] the 260 fields from which to select the main imprint
        def preferred_260(fields)
          fields.select { |field| field.indicator1 == '3' }.last || fields.last
        end

        # selects the preferred 264 field to use as the main imprint
        # @param fields [MARC::DataField] the 264 fields from which to select the main imprint
        def preferred_264(fields)
          fields.select { |field| field.indicator1 == '3' && field.indicator2 == '1' }.last ||
          fields.select { |field| field.indicator2 == '1' }.last ||
          fields.select { |field| field.indicator1 == '3' && field.indicator2 =~ /[023]/ }.last ||
          fields.select { |field| field.indicator2 != '4' }.last
        end

        # checks whether all the imprint fields are 260s
        # @param fields [MARC::DataField] all the imprint fields from the record
        def all_260s?(fields)
          fields.all? { |field| field.tag == '260' }
        end

        # checks whether all the imprint fields are 264s
        # @param fields [MARC::DataField] all the imprint fields from the record
        def all_264s?(fields)
          fields.all? { |field| field.tag == '264' }
        end
      end
    end
  end
end
