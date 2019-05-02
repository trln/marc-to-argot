module MarcToArgot
  module Macros
    module UNC
      module LocalSubjectGenre

        include MarcToArgot::Macros::Shared::SubjectGenre

        def local_subject_genre(rec, cxt)
          if rec.leader[6] == 'g'
            mrc_genre_fields(rec, cxt)
          end

          local_geog_fields(rec, cxt)
        end

        def mrc_genre_fields(rec, cxt)
          genres = []
          Traject::MarcExtractor.cached('690', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
            genres << field if is_local_genre?(field)
          end

          mrc_genres = genres.map { |f| f['a'] } if genres.length > 0

          cxt.output_hash['genre_unc_mrc'] = mrc_genres if mrc_genres
        end

        def is_local_genre?(field)
          return true if field.tag == '690' && field['2'] == 'local'
        end

        def local_geog_fields(rec, cxt)
          acc = []
          Traject::MarcExtractor.cached('691z').each_matching_line(rec) do |field, spec|
            values = collect_subjects(field, spec)
            acc.concat(values) unless values.nil? || values.empty?
          end

          Traject::MarcExtractor.cached('691ag').each_matching_line(rec) do |field, spec|
            value = collect_and_join_subjects(field, spec, ' -- ')
            acc << value unless value.nil? || value.empty?
          end

          acc.flatten!
          
          unless acc.empty?
            if cxt.output_hash.has_key?('subject_geographic')
              acc.each { |val| cxt.output_hash['subject_geographic'] << val }
            else
              cxt.output_hash['subject_geographic'] = acc
            end
            cxt.output_hash['subject_geographic'].uniq!
          end
      end
      
      
      end
    end
  end
end
