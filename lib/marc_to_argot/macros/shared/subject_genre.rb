module MarcToArgot
  module Macros
    module Shared
      module SubjectGenre
        ################################################################
        # subject/genre headings and facets macros
        ################################################################

        ################################################
        # subject headings
        ######

        def subject_headings
          lambda do |rec, acc|
            shared_spec = '600abcdfghjklmnopqrstuvxyz:'\
                          '610abcdfghklmnoprstuvxyz:'\
                          '611acdefghklnpqstuvxyz:'\
                          '630adfghklmnoprstvxyz:'\
                          '647acdgvxyz:'\
                          '648avxyz:'\
                          '650abcdgvxyz:'\
                          '651agvxyz:'\
                          '653|* |a:'\
                          '653|*0|a:'\
                          '653|*1|a:'\
                          '653|*2|a:'\
                          '653|*3|a:'\
                          '653|*4|a:'\
                          '653|*5|a:'\
                          '656akvxyz:'\
                          '657avxyz:'\
                          '662abcdfgh'
            local_spec = settings['specs'][:subject_headings_local]
            spec = [shared_spec, local_spec].compact.join(':')

            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec|
              headings = []

              value = collect_and_join_subjects(field, spec, ' -- ')
              lang = Vernacular::ScriptClassifier.new(field, value).classify

              # From a 653, create one subject heading per subfield
              if field.tag == '653' && value
                value.split(' -- ').each do |val|
                  field_values = {}
                  field_values[:value] = val unless val.nil? || val.empty?
                  field_values[:lang] = lang unless lang.nil? || lang.empty?
                  headings << field_values
                end

              # From all other fields, create one joined heading from each field
              else
                field_values = {}
                field_values[:value] = value unless value.nil? || value.empty?
                field_values[:lang] = lang unless lang.nil? || lang.empty?
                headings << field_values
              end

              headings.each { |h| acc << h if h.has_key?(:value) }
              acc.uniq!
            end
          end
        end

        ################################################
        # genre headings
        ######

        def genre_headings
          lambda do |rec, acc|
            shared_spec = '382a:382b:382d:382p:384a:567b:600v:610v:611v:630v:647v:648v:650v:651v:653| 6|a:655v:656kv:657v'
            local_spec = settings['specs'][:genre_headings_local_single_values]
            spec = [shared_spec, local_spec].compact.join(':')

            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec|
              next unless subfield_5_absent_or_present_with_local_code?(field)

              values = collect_subjects(field, spec)
              headings = values.map do |v|
                lang = Vernacular::ScriptClassifier.new(field, v).classify
                heading = {}
                heading[:value] = v
                heading[:lang] = lang unless lang.nil? || lang.empty?
                heading
              end
              acc.concat(headings) unless headings.empty?
            end

            shared_spec = '655avxyz'
            local_spec = settings['specs'][:genre_headings_local]
            spec = [shared_spec, local_spec].compact.join(':')

            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec|
              next unless subfield_5_absent_or_present_with_local_code?(field)

              heading = {}
              value = collect_655axyz(field, field.subfields.select { |sf| %w[a x y z].include?(sf.code) }, spec)
              lang = Vernacular::ScriptClassifier.new(field, value).classify
              heading[:value] = value unless value.nil? || value.empty?
              heading[:lang] = lang unless lang.nil? || lang.empty?
              acc << heading unless heading.empty?
            end

            acc.uniq!
          end
        end

        ################################################
        # subject topical facet
        ######

        def subject_topical
          lambda do |rec, acc|
            shared_spec = '600abcdfghjklmnopqrstux:'\
                          '610abcdfghklmnoprstux:'\
                          '611acdefghklnpqstux:'\
                          '630adfghklmnoprstx:'\
                          '647acdgx:'\
                          '648x:'\
                          '650abcdgx:'\
                          '651x:653|*0|a:653|*1|a:653|*2|a:'\
                          '653|*3|a:'\
                          '653|*4|a:'\
                          '656ax:'\
                          '657ax'
            local_spec = settings['specs'][:subject_topical_local]
            spec = [shared_spec, local_spec].compact.join(':')

            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec|

              values = collect_subjects(field, spec)

              acc.concat(values) unless values.nil? || values.empty?
              acc.uniq!
            end
          end
        end

        ################################################
        # subject chronological facet
        ######

        def subject_chronological
          lambda do |rec, acc|
            shared_spec = '600y:610y:611y:630y:'\
                          '648a:648y:650y:651y:'\
                          '655y:656y:657y'
            local_spec = settings['specs'][:subject_chronological_local]
            spec = [shared_spec, local_spec].compact.join(':')

            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec|
              next unless subfield_5_absent_or_present_with_local_code?(field)

              values = collect_subjects(field, spec)

              acc.concat(values) unless values.nil? || values.empty?
              acc.uniq!
            end
          end
        end

        ################################################
        # subject geographic facet
        ######

        def subject_geographic
          lambda do |rec, acc|
            shared_spec = '600z:610z:611z:630z:'\
                          '648z:650z:'\
                          '651z:'\
                          '653|*5|a:655z:656z:'\
                          '657z:662a:662b:662c:662d:662f:662g:662h'
            local_spec = settings['specs'][:subject_geographic_local]
            spec = [shared_spec, local_spec].compact.join(':')

            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec|
              next unless subfield_5_absent_or_present_with_local_code?(field)

              values = collect_subjects(field, spec)
              acc.concat(values) unless values.nil? || values.empty?
            end

            shared_spec = '651ag'
            local_spec = settings['specs'][:subject_geographic_local_concatenated]
            spec = [shared_spec, local_spec].compact.join(':')

            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec|
              value = collect_and_join_subjects(field, spec, ' -- ')
              acc << value unless value.nil? || value.empty?
            end

            acc.uniq!
          end
        end

        ################################################
        # subject genre facet
        ######

        def subject_genre
          lambda do |rec, acc|
            shared_spec = '382a:382b:382d:382p:384a:567b:'\
                          '600v:610v:611v:630v:647v:'\
                          '648v:650v:651v:653|*6|a:'\
                          '655v:656v:656k:657v'
            local_spec = settings['specs'][:subject_genre_local]
            spec = [shared_spec, local_spec].compact.join(':')

            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec|
              next unless subfield_5_absent_or_present_with_local_code?(field)

              values = collect_subjects(field, spec)
              acc.concat(values) unless values.nil? || values.empty?
            end

            shared_spec = '655ax'
            local_spec = settings['specs'][:subject_genre_local_concatenated]
            spec = [shared_spec, local_spec].compact.join(':')

            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec|
              next unless subfield_5_absent_or_present_with_local_code?(field)

              value = collect_655axyz(field, field.subfields.select { |sf| %w[a x].include?(sf.code) }, spec)
              acc << value unless value.nil? || value.empty?
            end

            acc.concat(argot_genre_from_fixed_fields(rec))

            acc << set_primary_source_genre(acc)
            acc << set_reference_genre(acc)

            acc.uniq!
          end
        end

        def set_primary_source_genre(genre_values)
          primary_source_genres = ['Archival resources',
                           'Archives',
                           'Correspondence',
                           'Diaries',
                           'Interviews',
                           'Interview',
                           'Notebooks, sketchbooks, etc',
                           'Personal narratives',
                           'Sources',
                           'Speeches, addresses, etc']
          return 'Primary sources' if !(genre_values & primary_source_genres).empty?
        end

        def set_reference_genre(genre_values)
          reference_genres = ['Bibliography',
                              'Bio-bibliography',
                              'Dictionaries',
                              'Directories',
                              'Encyclopedias',
                              'Handbooks, manuals, etc.',
                              'Handbooks, manuals, etc',
                              'Identification',
                              'Identification guides',
                              'Indexes',
                              'Style manuals']
          return 'Reference' if !(genre_values & reference_genres).empty?
        end

        def argot_genre_from_fixed_fields(rec)
          #set relevant byte positions for each field
          lit_form_008 = 33
          bio_008 = 34
          lit_form_006 = 16
          bio_006 = 17

          genre_values = []
          Traject::MarcExtractor.cached('008:006', alternate_script: false).each_matching_line(rec) do |field, spec|
            to_map = []
            if field.tag == '008' && rec.uses_book_configuration_in_008?
              to_map << get_bytes_to_map(field, lit_form_008, bio_008)
            elsif field.tag == '006' && field.uses_book_configuration_in_006?
              to_map << get_bytes_to_map(field, lit_form_006, bio_006)
            end

            unless to_map.empty?
              to_map.each do |bytevals|
                genre_values << map_byte_value_to_genre(bytevals['lit_form'])
                genre_values << 'Biography' if bytevals['bio'] && bytevals['bio'].scrub =~ /[abcd]/
              end
            end
          end
          genre_values
        end

        def get_bytes_to_map(field, lit_form_byte, bio_byte)
          values = {}
          values['lit_form'] = field.value.byteslice(lit_form_byte)
          values['bio'] = field.value.byteslice(bio_byte)
          values
        end

        def map_byte_value_to_genre(byte_value)
          case byte_value
          when '0'
            'Nonfiction'
          when '1'
            'Fiction'
          when 'd'
            'Drama'
          when 'e'
            'Essays'
          when 'f'
            'Novels'
          when 'h'
            'Humor, satire, etc'
          when 'i'
            'Letters'
          when 'j'
            'Short stories'
          when 'p'
            'Poetry'
          when 's'
            'Speeches, addresses, etc'
          end
        end

        ################################################
        # subject remapping methods
        ######
        # NOTE: remapping is now supported for topical, chronological, geographic, and genre terms.

        # Subjects to be remapped are specified and must match at the whole heading-or-subdivision
        #  level. This is to ensure we don't end up inadvertently changing stuff that shouldn't be
        #  changed. For example,
        #    "Poor -- Medical care" should be remapped to "Poor people -- Medical care"
        #  but
        #    "Poor children -- United States" should NOT be remapped to "Poor people children --
        #      United States"
        SUBJECT_REMAP = Traject::TranslationMap.new('shared/subject_heading_remappings').hash
        REMAP_SEGMENTS = SUBJECT_REMAP.keys

        def remap_subjects(rec, ctx)
          remap_subject_facets(rec, ctx, 'subject_topical')
          remap_subject_facets(rec, ctx, 'subject_geographic')
          remap_subject_facets(rec, ctx, 'subject_chronological')
          remap_subject_facets(rec, ctx, 'subject_genre')
          remap_headings(rec, ctx, 'subject_headings')
          remap_headings(rec, ctx, 'genre_headings')
        end

        # Remap uncoordinated terms used in facets
        # The fields have the form of an array of terms
        # ['term one', 'term two', 'term three']
        def remap_subject_facets(rec, ctx, key)
          subjects_in_record = ctx.output_hash[key]
          return unless subjects_in_record

          remapped_segments = subjects_in_record.map do |orig_subj|
            subject_segment_remapper(orig_subj)
          end

          ctx.output_hash[key] = remapped_segments.uniq
        end

        # Remap coordinated terms used in facets
        # The fields have the form of an array of hashes.
        # [{ value: 'term one -- term two -- term three' }]
        def remap_headings(rec, ctx, key)
          headings_in_record = ctx.output_hash[key]
          return unless headings_in_record

          ctx.output_hash[key] = remapped_headings(headings_in_record)
          rej_headings = rejected_headings(headings_in_record)
          return if rej_headings.empty?

          ctx.output_hash["#{key}_remapped"] = rej_headings
        end

        # Break apart, remap if needed, and recombine
        # coordinated terms.
        def remapped_headings(original_subjects)
          remapped = original_subjects.map do |orig_subj|
            segments = orig_subj[:value].split(' -- ')
            remapped_segments = segments.map do |segment|
              subject_segment_remapper(segment)
            end
            orig_subj.merge({ value: remapped_segments.join(' -- ') })
          end

          remapped.flatten.uniq
        end

        # Identify and return any headings that have been remapped.
        def rejected_headings(original_headings)
          rejected = original_headings.select do |heading|
            (heading[:value].split(' -- ').map(&:downcase) & REMAP_SEGMENTS).any?
          end

          rejected.map { |s| s[:value] }
        end

        # Remap uncoordinated terms if needed.
        def subject_segment_remapper(segment)
          if REMAP_SEGMENTS.include?(segment.downcase)
            SUBJECT_REMAP[segment.downcase]
          else
            segment
          end
        end

        ################################################
        # subject genre helpers
        ######

        def collect_subjects(field, spec)
          codes_with_subdivisions = codes_and_clean_subdivisions(field, spec)
          subdivisions = assemble_subdivisions(codes_with_subdivisions, field, spec)
          subdivisions.map { |sf| Traject::Macros::Marc21.trim_punctuation(sf) }
        end

        def collect_and_join_subjects(field, spec, separator)
          collect_subjects(field, spec).join(separator)
        end

        def collect_655axyz(field, subfields, spec)
          sfs = subfields.map { |sf| [sf.code, strip_rb_vocab_terms(field, sf).gsub(/\)\.$/, ')')] }
          joined_subdivisions = assemble_subdivisions(sfs, field, spec).join(' -- ')
          Traject::Macros::Marc21.trim_punctuation(capitalize_first_letter(joined_subdivisions))
        end

        def codes_and_clean_subdivisions(field, spec)
          field.subfields.collect do |sf|
            if spec.includes_subfield_code?(sf.code)
              [sf.code, capitalize_first_letter(sf.value).gsub(/\)\.$/, ')')]
            end
          end.compact
        end

        def assemble_subdivisions(codes_with_subdivisions, field, spec)
          subdivisions = []

          # remove any arrays from the array that don't have two entries
          # should be of the pattern [[code,value],[code,value]]
          codes_with_subdivisions.delete_if { |a| a.length != 2 }

          if spec.joinable? && !codes_with_subdivisions.empty?
            subdivisions = [codes_with_subdivisions.shift[1]]

            codes_with_subdivisions.each do |sf|
              if subdivide_at_subfields(field).include?(sf[0])
                subdivisions << sf[1]
              else
                current_subdivision_index = subdivisions.length - 1
                subdivisions[current_subdivision_index] << " #{sf[1]}"
              end
            end
          else
            subdivisions = codes_with_subdivisions.map(&:last)
          end

          subdivisions
        end

        def subdivide_at_subfields(field)
          case field_tag_or_880_linkage_tag(field)
          when '600', '610', '611', '630', '650'
            %w[v x y z]
          when '651'
            %w[g x v y z]
          when '655'
            %w[v x y z]
          when '656'
            %w[a k v x y z]
          when '662'
            %w[a b c d f g h]
          when '690'
            %w[a v x y z]
          when '691'
            %w[g x v y z]
          when '695'
            %w[a x]
          else
            %w[na]
          end
        end

        def strip_rb_vocab_terms(field, subfield)
          subfield_2 = field.subfields.select { |sf| sf.code == '2' }.map(&:value).first
          if subfield.code == 'a' && field.indicator2 == '7' && rb_terms.include?(subfield_2)
            return subfield.value.gsub(/ \((Binding|Genre|Paper|Printing|Provenance|Publishing|Type)\)/i, '')
          else
            return subfield.value
          end
        end

        def rb_terms
          %w[rbbin rbgenr rbmscv rbpap rbpri rbprov rbpub rbtyp]
        end
      end
    end
  end
end
