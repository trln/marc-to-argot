module MarcToArgot
  module Macros
    module UNC
      module LocalSubjectGenre

        include MarcToArgot::Macros::Shared::SubjectGenre


        def local_subject_genre(rec, cxt)
          if rec.leader[6] == 'g'
            mrc_genre_fields(rec, cxt)
          end
          local_genre_fields(rec, cxt)
          local_geog_fields(rec, cxt)
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
          return true if field['2'].start_with?('uncmrc')
        end

        def is_mrc_genre_dropdown_value?(field)
          mrc_dropdown_genres ||= Traject::TranslationMap.new('unc/mrc_dropdown_genres')
          val = field['a'].downcase.strip
          lkup = mrc_dropdown_genres[val]
          return true if lkup
        end

        def local_genre_fields(rec, cxt)
          acc = []
          Traject::MarcExtractor.cached('690v:691v:695a:695v:698v').each_matching_line(rec) do |field, spec|
            values = collect_subjects(field, spec)
            acc.concat(values) unless values.nil? || values.empty?
#            acc << value unless value.nil? || value.empty?
          end

          acc.flatten!
          
          unless acc.empty?
            if cxt.output_hash.has_key?('subject_genre')
              acc.each { |val| cxt.output_hash['subject_genre'] << val }
            else
              cxt.output_hash['subject_genre'] = acc
            end
            cxt.output_hash['subject_genre'].uniq!
          end
        end
        
        def local_geog_fields(rec, cxt)
          acc = []
          Traject::MarcExtractor.cached('691az').each_matching_line(rec) do |field, spec|
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
