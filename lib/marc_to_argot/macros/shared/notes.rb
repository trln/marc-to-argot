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
              next unless subfield_5_absent_or_present_with_local_code?(field)

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
          lambda do |rec, acc|
            Traject::MarcExtractor.cached("563au").each_matching_line(rec) do |field, spec, extractor|
              next unless subfield_5_absent_or_present_with_local_code?(field)

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
              next unless subfield_5_absent_or_present_with_local_code?(field)

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
              notes << ['Attribute accuracy: ', collect_and_join_subfield_values(field, %w[a b c], ' -- ')]
              notes << ['Logical consistency: ', collect_and_join_subfield_values(field, 'd', ' -- ')]
              notes << ['Horizontal position accuracy: ', collect_and_join_subfield_values(field, %w[f g h], ' -- ')]
              notes << ['Vertical position accuracy: ', collect_and_join_subfield_values(field, %w[i j k], ' -- ')]
              notes << ['Cloud cover: ', collect_and_join_subfield_values(field, 'm', ' -- ')]
              notes << ['Other data details: ', collect_and_join_subfield_values(field, %w[e u z])]
              acc.concat notes.select { |note| !note[1].empty? }.map(&:join)
            end
          end
        end

        ################################################
        # Note Described By
        ######
        def note_described_by
          lambda do |rec, acc|
            Traject::MarcExtractor.cached("555abcdu3").each_matching_line(rec) do |field, spec, extractor|
              next unless subfield_5_absent_or_present_with_local_code?(field)

              label = field.subfields.select { |sf| sf.code == '3' }.map(&:value).first
              case field.indicator1
              when ' '
                typelabel = 'Indexes'
              when '0'
                typelabel = 'Finding aids'
              end
              value = collect_and_join_subfield_values(field, %w[a b c d u])
              acc << [label, typelabel, value].compact.join(': ') if value
            end
          end
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
      # Note General
      ######
      def note_general
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("500a:504ab:518adop:521ab:522a:526abcdz:536abcdefgh:546ab:556a:585a:586a").each_matching_line(rec) do |field, spec, extractor|
            notes = {}

            label = note_general_label(field)
            notes[:label] = label unless label.nil? || label.empty?

            value = note_general_value(field, spec, extractor)
            notes[:value] = value unless value.nil? || value.empty?

            indexed_value = note_general_indexed_value(field)
            notes[:indexed_value] = indexed_value unless indexed_value.nil? || indexed_value.empty?

            indexed = note_general_indexed(field)
            notes[:indexed] = indexed unless indexed.nil? || indexed.empty?

            next if (notes[:value].nil? || notes[:value].empty?) &&
                    (notes[:indexed_value].nil? || notes[:indexed_value].empty?)

            acc << notes
          end
        end
      end

      def note_general_label(field)
        labels = []
        case field_tag_or_880_linkage_tag(field)
        when /^(500|518|546|585|586)$/
          labels << collect_subfield_values_by_code(field, '3').join(' ')
        when '521'
          labels << collect_subfield_values_by_code(field, '3').join(' ').chomp(':').capitalize
          case field.indicator1
          when '0'
            labels << 'For grade(s)'
          when '1'
            labels << 'For age(s)'
          when '2'
            labels << 'For grade(s)'
          when /(3|4| )/
            labels << 'For audience(s)'
          end
        when '522'
          labels << 'Geographic coverage' if field.indicator1 == ' '
        when '526'
          labels << 'Reading program' if field.indicator1 == '0'
          labels << collect_subfield_values_by_code(field, 'i').join(' ').chomp(':').capitalize
        when '536'
          labels << 'Funding details'
        when '556'
          labels << 'Documentation' if field.indicator1 == ' '
        end

        labels.compact.reject(&:empty?).join(': ')
      end

      def note_general_value(field, spec, extractor)
        case field_tag_or_880_linkage_tag(field)
        when '500'
          unless subfield_5_present?(field)
            extractor.collect_subfields(field, spec).first
          end
        when '504'
          notes = []
          notes << ['', collect_and_join_subfield_values(field, 'a')]
          notes << ['Number of references: ', collect_and_join_subfield_values(field, 'b')]
          notes.select { |note| !note[1].empty? }.map(&:join).join(' ')
        when '521'
          b_value = collect_and_join_subfield_values(field, 'b')
          notes = []
          notes << collect_and_join_subfield_values(field, 'a', '; ')
          notes << "(source: #{b_value})" unless b_value.empty?
          notes.compact.reject(&:empty?).join(' ')
        when '526'
          notes = []
          notes << ['', collect_and_join_subfield_values(field, 'a')]
          notes << ['Interest level: ', collect_and_join_subfield_values(field, 'b')]
          notes << ['Reading level: ', collect_and_join_subfield_values(field, 'c')]
          notes << ['Title points: ', collect_and_join_subfield_values(field, 'd')]
          notes << ['', collect_and_join_subfield_values(field, 'z', ' -- ')]
          notes.select { |note| !note[1].empty? }.map(&:join).join(' -- ')
        when '585'
          if subfield_5_absent_or_present_with_local_code?(field)
            extractor.collect_subfields(field, spec).first
          end
        else
          extractor.collect_subfields(field, spec).first
        end
      end

      def note_general_indexed_value(field)
        case field_tag_or_880_linkage_tag(field)
        when '526'
          if (%w[b c d z] & field.subfields.map(&:code)).any?
            collect_and_join_subfield_values(field, 'a')
          end
        end
      end

      def note_general_indexed(field)
        case field_tag_or_880_linkage_tag(field)
        when /^(504|518|521|556)$/
          'false'
        end
      end

      ################################################
      # Note Local
      ######
      def note_local
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("500a:541abcdefhno3:561a:590a").each_matching_line(rec) do |field, spec, extractor|
            next unless subfield_5_absent_or_present_with_local_code?(field)

            notes = {}

            label = note_local_label(field)
            notes['label'] = label unless label.nil? || label.empty?

            value = note_local_value(field, spec, extractor)
            notes['value'] = value unless value.nil? || value.empty?

            indexed_value = note_local_indexed_value(field)
            notes['indexed_value'] = indexed_value unless indexed_value.nil? || indexed_value.empty?

            next if (notes['value'].nil? || notes['value'].empty?) &&
                    (notes['indexed_value'].nil? || notes['indexed_value'].empty?)

            acc << notes
          end
        end
      end

      def note_local_label(field)
        labels = []
        case field_tag_or_880_linkage_tag(field)
        when '500'
          labels << collect_subfield_values_by_code(field, '3').join(' ')
        when '541'
          labels << 'Source of acquisition'
        when '561'
          labels << 'Ownership history'
          labels << collect_subfield_values_by_code(field, '3').join(' ')
        end

        labels.compact.reject(&:empty?).join(': ')
      end

      def note_local_value(field, spec, extractor)
        case field_tag_or_880_linkage_tag(field)
        when '500'
          if subfield_5_present_with_local_code?(field)
            extractor.collect_subfields(field, spec).first
          end
        when '561'
          unless field.indicator1 == '0'
            extractor.collect_subfields(field, spec).first
          end
        else
          extractor.collect_subfields(field, spec).first
        end
      end

      def note_local_indexed_value(field)
        case field_tag_or_880_linkage_tag(field)
        when '541'
          collect_subfield_values_by_code(field, 'a').join(' ')
        end
      end

      ################################################
      # Note Organization
      ######
      def note_organization
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("351abc").each_matching_line(rec) do |field, spec, extractor|
            label = field.subfields.select { |sf| sf.code == '3' }.map { |sf| sf.value.chomp(':') }
            value = extractor.collect_subfields(field, spec).first
            acc << [*label, value].compact.join(': ') if value
          end
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
      # Note Preferred Citation
      ######
      def note_preferred_citation
        lambda do |rec, acc|
          Traject::MarcExtractor.cached('524a').each_matching_line(rec) do |field, spec, extractor|
            next unless subfield_5_absent_or_present_with_local_code?(field)
            label = collect_subfield_values_by_code(field, '3').compact.reject(&:empty?).join(': ')
            label = label.sub(/:\s*$/, '') if label
            value = extractor.collect_subfields(field, spec).first.gsub(/preferred citation:?\s*/i, '')
            acc << [label, value].compact.reject(&:empty?).join(': ') if value
          end
        end
      end

      ################################################
      # Note Related Work
      ######
      def note_related_work
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("535abcdg:544abcden:580a:581az").each_matching_line(rec) do |field, spec, extractor|
            notes = {}

            label = note_related_work_label(field)
            notes[:label] = label unless label.nil? || label.empty?

            value = note_related_work_value(field, spec, extractor)
            notes[:value] = value unless value.nil? || value.empty?

            indexed_value = note_related_work_indexed_value(field)
            notes[:indexed_value] = indexed_value unless indexed_value.nil? || indexed_value.empty?

            indexed = note_related_work_indexed(field)
            notes[:indexed] = indexed unless indexed.nil? || indexed.empty?

            next if (notes[:value].nil? || notes[:value].empty?) &&
                    (notes[:indexed_value].nil? || notes[:indexed_value].empty?)

            acc << notes
          end
        end
      end

      def note_related_work_label(field)
        labels = []
        case field_tag_or_880_linkage_tag(field)
        when '535'
          labels << collect_subfield_values_by_code(field, '3').join(' ')
          labels << 'Originals held by' if field.indicator1 == '1'
          labels << 'Duplicates held by' if field.indicator1 == '2'
        when '544'
          labels << collect_subfield_values_by_code(field, '3').join(' ')
          labels << 'Related materials' if %w[0 1].include?(field.indicator1)
        when '581'
          if field.subfields.map(&:code).include?('3')
            sf3 = collect_subfield_values_by_code(field, '3').join(' ')
            labels << "Publications relating to #{sf3.downcase}"
          else
            labels << 'Related publications'
          end
        end

        labels.compact.reject(&:empty?).join(': ')
      end

      def note_related_work_value(field, spec, extractor)
        case field_tag_or_880_linkage_tag(field)
        when '535', '544', '580'
          extractor.collect_subfields(field, spec).first
        when '581'
          field.subfields.map do |sf|
            if sf.code == 'z'
              "ISBN #{sf.value}"
            elsif sf.code =~ /[a]/
              sf.value
            end
          end.compact.reject(&:empty?).join(' ')
        end
      end

      def note_related_work_indexed_value(field)
        case field_tag_or_880_linkage_tag(field)
        when '544'
          collect_subfield_values_by_code(field, 'd').join(' ')
        end
      end

      def note_related_work_indexed(field)
        case field_tag_or_880_linkage_tag(field)
        when '535'
          'false'
        when '544'
          'false' unless field.subfields.map(&:code).include?('d')
        when '580'
          'false'
        when '581'
          'false'
        end
      end

      ################################################
      # Note Reproduction
      ######
      def note_reproduction
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("533abcdefmn:534abcefklmnotxz").each_matching_line(rec) do |field, spec, extractor|
            next unless subfield_5_absent_or_present_with_local_code?(field)
            notes = {}

            label = note_reproduction_label(field)
            notes[:label] = label unless label.nil? || label.empty?

            value = extractor.collect_subfields(field, spec).first
            notes[:value] = value unless value.nil? || value.empty?

            indexed_value = note_reproduction_indexed_value(field)
            notes[:indexed_value] = indexed_value unless indexed_value.nil? || indexed_value.empty?

            indexed = note_reproduction_indexed(field)
            notes[:indexed] = indexed unless indexed.nil? || indexed.empty?

            next if (notes[:value].nil? || notes[:value].empty?) &&
                    (notes[:indexed_value].nil? || notes[:indexed_value].empty?)

            acc << notes
          end
        end
      end

      def note_reproduction_label(field)
        labels = []
        case field_tag_or_880_linkage_tag(field)
        when '533'
          labels << collect_subfield_values_by_code(field, '3').join(' ')
        when '534'
          labels << collect_subfield_values_by_code(field, '3').join(' ')
          if field.subfields.map(&:code).include?('p')
            labels << collect_subfield_values_by_code(field, 'p').join(' ').chomp(':')
          else
            labels << 'Original version'
          end
        end
        labels.compact.reject(&:empty?).join(': ')
      end

      def note_reproduction_indexed_value(field)
        case field_tag_or_880_linkage_tag(field)
        when '533'
          field.subfields.select { |sf| %w[c f].include?(sf.code) }.map(&:value).join(' ')
        when '534'
          if field.subfields.map(&:code).include?('p') && (%w[a t k] & field.subfields.map(&:code)).any?
            field.subfields.select { |sf| %w[a t k].include?(sf.code) }.map(&:value).join(' ')
          end
        end
      end

      def note_reproduction_indexed(field)
        case field_tag_or_880_linkage_tag(field)
        when '533'
          return 'false' if (%w[c f] & field.subfields.map(&:code)).empty?
        when '534'
          return 'false' if (field.subfields.map(&:code).include?('p') &&
                            (%w[a t k] & field.subfields.map(&:code)).empty?) ||
                            !field.subfields.map(&:code).include?('p')
        end
      end

      ###############################################
      #Note serial dates
      #########
      def note_serial_dates
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("362az").each_matching_line(rec) do |field, spec, extractor|
            next unless subfield_5_absent_or_present_with_local_code?(field)
            a = field.subfields.select { |sf| sf.code == 'a' }.map { |sf| sf.value }
            z = field.subfields.select { |sf| sf.code == 'z' }.map { |sf| "(#{sf.value.gsub(/Cf./i, "Data from:")})" }
            acc << [a,z].compact.join(' ').rstrip
          end
        end
      end

      ################################################
      # Note Cited In
      ######
      def note_cited_in
        lambda do |rec, acc|
          Traject::MarcExtractor.cached('510abcux3').each_matching_line(rec) do |field, spec, extractor|
            next unless subfield_5_absent_or_present_with_local_code?(field)
            notes = {}

            label = note_cited_in_label(field)
            notes[:label] = label unless label.nil? || label.empty?

            value = note_cited_in_value(field, spec, extractor)
            notes[:value] = value unless value.nil? || value.empty?

            indexed_value = note_cited_in_indexed_value(field)
            notes[:indexed_value] = indexed_value unless indexed_value.nil? || indexed_value.empty? || indexed_value == value

            next if (notes[:value].nil? || notes[:value].empty?) &&
                    (notes[:indexed_value].nil? || notes[:indexed_value].empty?)

            acc << notes
          end
        end
      end

      def note_cited_in_label(field)
        labels = []
        labels << collect_subfield_values_by_code(field, '3').join(' ')
        labels.compact.reject(&:empty?).join(': ')
      end

      def note_cited_in_value(field, spec, extractor)
        value = []
        field.subfields.each do |sf|
          if sf.code == 'x'
            value << "ISSN #{sf.value}"
          elsif sf.code =~ /[abcu]/
            value << sf.value
          end
        end
        return value.join(' ')
      end

      def note_cited_in_indexed_value(field)
        value = []
        field.subfields.each{ |sf| value << sf.value if 'abc'.include?(sf.code) }
        return value.join(' ')
      end


      ################################################
      # Note System Details
      ######
      def note_system_details
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("538au").each_matching_line(rec) do |field, spec, extractor|
            next unless subfield_5_absent_or_present_with_local_code?(field)
            label = field.subfields.select { |sf| %w[3 i].include?(sf.code) }.map { |sf| sf.value.chomp(':') }
            value = extractor.collect_subfields(field, spec).first
            acc << [*label, value].compact.join(': ') if value
          end
        end
      end


      ################################################
      # Note Use Terms
      ######
      def note_use_terms
        lambda do |rec, acc|
          Traject::MarcExtractor.cached('540abcdfgqu').each_matching_line(rec) do |field, spec, extractor|
            next unless subfield_5_absent_or_present_with_local_code?(field)
            label = collect_subfield_values_by_code(field, '3').compact.reject(&:empty?).join(': ')
            value = extractor.collect_subfields(field, spec).first
            acc << [label, value].compact.reject(&:empty?).join(': ') if value
          end
        end
      end


      ################################################
      # Note With
      ######
      def note_with
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("501a").each_matching_line(rec) do |field, spec, extractor|
            next unless subfield_5_absent_or_present_with_local_code?(field)

            acc << extractor.collect_subfields(field, spec).first
          end
        end
      end
    end
  end
end
