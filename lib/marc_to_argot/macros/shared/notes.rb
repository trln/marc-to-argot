module MarcToArgot
  module Macros
    module Shared
      module Notes
        ################################################
        # Note Access Restrictions
        ######
        def note_access_restrictions
          lambda do |rec, acc|
            Traject::MarcExtractor.cached("506abcdefu").each_matching_line(rec) do |field, spec, extractor|
              label = field.subfields.select { |sf| sf.code == '3' }.map(&:value).first
              value = extractor.collect_subfields(field, spec).first
              acc << [label, value].compact.join(': ') if value
            end
          end
        end

        ################################################
        # Note Binding
        ######
        def note_binding
          # TODO: Exclude some based on $5 codes, TDB
          lambda do |rec, acc|
            Traject::MarcExtractor.cached("563au").each_matching_line(rec) do |field, spec, extractor|
              note = {}
              label = field.subfields.select { |sf| sf.code == '3' }.map(&:value).first
              value = extractor.collect_subfields(field, spec).first
              note[:label] = label if label
              note[:value] = value if value
              acc << note if note[:value]
            end
          end
        end

        ################################################
        # Note Biographical
        ######
        def note_biographical
          lambda do |rec, acc|
            Traject::MarcExtractor.cached("545abu").each_matching_line(rec) do |field, spec, extractor|
              acc << extractor.collect_subfields(field, spec).first unless field.indicator1 == '1'
            end
          end
        end

        ################################################
        # Note Copy Version
        ######
        def note_copy_version
          lambda do |rec, acc|
            Traject::MarcExtractor.cached("562abcde").each_matching_line(rec) do |field, spec, extractor|
              label = field.subfields.select { |sf| sf.code == '3' }.map(&:value).first
              value = extractor.collect_subfields(field, spec).first
              acc << [label, value].compact.join(': ') if value
            end
          end
        end

        ################################################
        # Note Data Quality
        ######
        def note_data_quality
          lambda do |rec, acc|
            Traject::MarcExtractor.cached("514abcdefghijkmuz").each_matching_line(rec) do |field, spec, extractor|
              notes = []
              notes << ['Attribute accuracy: ', note_data_quality_value(field, %w[a b c] )]
              notes << ['Logical consistency: ', note_data_quality_value(field, 'd')]
              notes << ['Horizontal position accuracy: ', note_data_quality_value(field, %w[f g h])]
              notes << ['Vertical position accuracy: ', note_data_quality_value(field, %w[i j k] )]
              notes << ['Cloud cover: ', note_data_quality_value(field, 'm' )]
              notes << ['Other data details: ', note_data_quality_value(field, %w[e u z], ' ')]
              acc.concat notes.select { |note| !note[1].empty? }.map(&:join)
            end
          end
        end

        def note_data_quality_value(field, subfields_spec, separator = ' -- ')
          field.subfields.select { |sf| [*subfields_spec].include?(sf.code) }.map(&:value).join(separator)
        end

        ################################################
        # Note Dissertation
        ######
        def note_dissertation
          lambda do |rec, acc|
            Traject::MarcExtractor.cached("502abcdgo").each_matching_line(rec) do |field, spec, extractor|
              value = note_dissertation_value(field, spec)
              acc << value if value
            end
          end
        end

        def note_dissertation_value(field, spec)
          subfield_codes = field.subfields.map(&:code)
          subfield_codes.shift if subfield_codes.first == '6'
          joined_sf_values = join_dissertation_sf_values(field, spec)
          return joined_sf_values if %w[a b g].include?(subfield_codes.first)
          "Thesis/disseration--#{joined_sf_values}"
        end

        def join_dissertation_sf_values(field, spec)
          fields = field.subfields.select { |sf| spec.subfields.include?(sf.code) }
          prefixed_fields = fields.map { |f| f.code == 'd' ? ", #{f.value}" : "--#{f.value}" }
          prefixed_fields.join.reverse.chomp('--').reverse
        end
      end

      ################################################
      # Note Performer Credits
      ######
      def note_performer_credits
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("511a").each_matching_line(rec) do |field, spec, extractor|
            note = {}
            value = extractor.collect_subfields(field, spec).first
            note[:label] = 'Cast' if field.indicator1 == '1'
            note[:value] = value if value
            acc << note if note[:value]
          end
        end
      end

      ################################################
      # Note System Details
      ######
      def note_system_details
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("538au").each_matching_line(rec) do |field, spec, extractor|
              label = field.subfields.select { |sf| %w[3 i].include?(sf.code) }.map { |sf| sf.value.chomp(':') }
              value = extractor.collect_subfields(field, spec).first
              acc << [*label, value].compact.join(': ') if value
          end
        end
      end
    end
  end
end
