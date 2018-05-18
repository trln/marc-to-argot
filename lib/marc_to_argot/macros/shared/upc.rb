module MarcToArgot
  module Macros
    module Shared
      module Upc
        ################################################
        # UPC
        ######

        def upc
          lambda do |rec, acc|
            Traject::MarcExtractor.cached('024adz')
                                  .each_matching_line(rec) do |field, spec, extractor|
              case field.tag
              when '024'
                acc.concat upc_024(field)
              end
            end
            acc.uniq!
          end
        end


        ################################################
        # MARC 024 Processor
        ######

        def upc_024(field)
          ids = []
          id_subfields = 'az'
          qual_subfields = 'dq'

          if field.indicator1 == '1'
            split_fields = split_complex_id_field(field, id_subfields, qual_subfields)

            split_fields.each do |sfield|
              id_hash = assemble_id_hash(upc_value_from_024(sfield, id_subfields),
                                         qual: gather_qualifiers(sfield, id_subfields, qual_subfields),
                                         type: upc_type_from_024(sfield))
              ids << id_hash if id_hash.has_key?('value')
            end
          end

          ids
        end

        def upc_value_from_024(field, id_subfields)
          sfs = field.subfields.select { |sf| id_subfields.include?(sf.code) }
          return extract_identifier(sfs[0].value) if sfs.any?
        end

        def upc_type_from_024(field)
          type = "UPC"
          type = "#{type} #{cancelled_type}" if subfields_present(field).include?('z')
          type
        end
      end
    end
  end
end
