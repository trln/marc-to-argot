module MarcToArgot
  module Macros
    module UNC
      module LocalSubjectGenre

        include MarcToArgot::Macros::Shared::SubjectGenre


        def local_subject_genre(rec, cxt)
          if rec.leader[6] == 'g'
            mrc_genre_fields(rec, cxt)
          end
        end

        def mrc_genre_fields(rec, cxt)
          genres = []
          Traject::MarcExtractor.cached('690:695', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
            genres << field if is_mrc_heading?(field) && is_mrc_genre_dropdown_value?(field)
          end

          mrc_genres = genres.map { |f| f['a'].strip } if genres.length > 0

          cxt.output_hash['genre_unc_mrc'] = mrc_genres if mrc_genres
        end

        def is_mrc_heading?(field)
          return true if field['2'] && field['2'].start_with?('uncmrc')
        end

        def is_mrc_genre_dropdown_value?(field)
          mrc_dropdown_genres ||= Traject::TranslationMap.new('unc/mrc_dropdown_genres')
          val = field['a'].downcase.strip
          lkup = mrc_dropdown_genres[val]
          return true if lkup
        end
      end
    end
  end
end
