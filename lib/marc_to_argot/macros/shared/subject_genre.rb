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
            spec = '600abcdfghjklmnopqrstuvxyz:'\
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
                   '662abcdfgh:'\
                   '690ax:'\
                   '691abvxyz:'\
                   '695a'
            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec|
              field_values = {}

              value = collect_and_join_subjects(field, spec, ' -- ')
              lang = Vernacular::ScriptClassifier.new(field, value).classify

              field_values[:value] = value unless value.nil? || value.empty?
              field_values[:lang] = lang unless lang.nil? || lang.empty?

              acc << field_values if field_values.has_key?(:value)
              acc.uniq!
            end
          end
        end

        ################################################
        # genre headings
        ######

        def genre_headings
          lambda do |rec, acc|
            spec = '382a:382b:382d:382p:384a:567b:600v:610v:611v:630v:647v:648v:650v:651v:653| 6|a:655v:656kv:657v'
            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec|
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

            Traject::MarcExtractor.cached('655axyz').each_matching_line(rec) do |field, spec|
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
            spec = '600abcdfghjklmnopqrstux:'\
                   '610abcdfghklmnoprstux:'\
                   '611acdefghklnpqstux:'\
                   '630adfghklmnoprstx:'\
                   '647acdgx:'\
                   '648x:'\
                   '650abcdgx:'\
                   '651x:653|*0|a:653|*1|a:653|*2|a:'\
                   '653|*3|a:'\
                   '656ax:'\
                   '657ax'
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
            spec = '600y:610y:611y:630y:'\
                   '648a:650y:651y:653|*4|a:'\
                   '655y:656y:657y'
            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec|

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
            spec = '600z:610z:611z:630z:'\
                   '648z:650z:'\
                   '651z:'\
                   '653|*5|a:655z:656z:'\
                   '657z:662a:662b:662c:662d:662f:662g:662h'
            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec|
              values = collect_subjects(field, spec)
              acc.concat(values) unless values.nil? || values.empty?
            end

            Traject::MarcExtractor.cached('651ag').each_matching_line(rec) do |field, spec|
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
            spec = '382a:382b:382d:382p:384a:567b:'\
                   '600v:610v:611v:630v:647v:'\
                   '648v:650v:651v:653|*6|a:'\
                   '655v:656v:656k:657v'
            Traject::MarcExtractor.cached(spec).each_matching_line(rec) do |field, spec|
              values = collect_subjects(field, spec)
              acc.concat(values) unless values.nil? || values.empty?
            end

            Traject::MarcExtractor.cached('655ax').each_matching_line(rec) do |field, spec|
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
                genre_values << 'Biography' if bytevals['bio'] =~ /[abcd]/
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
          when '653'
            %w[a]
          when '655'
            %w[v x y z]
          when '656'
            %w[a k v x y z]
          when '662'
            %w[a b c d f g h]
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
