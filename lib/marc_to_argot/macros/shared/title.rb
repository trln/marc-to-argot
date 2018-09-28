module MarcToArgot
  module Macros
    module Shared
      module Title

        # populates the 'short_title' of a Traject output_hash
        # if the title is
        def short_titles!(output_hash, max_length = 4)
          main_title = output_hash.fetch('title_main', '')
          return if main_title.empty?
          words = main_title.first[:value].split(/\s+/)
          if words.length <= max_length
            output_hash["short_title"] = words.join(' ')
          end
        end
        
        ################################################
        # Title Main
        ######
        def title_main
          lambda do |rec, acc|
            Traject::MarcExtractor.cached("245abfghknps").each_matching_line(rec) do |field, spec, extractor|
              title_main = {}

              value = title_value(field)
              lang = Vernacular::ScriptClassifier.new(field, value).classify

              title_main[:value] = value unless value.nil? || value.empty?
              title_main[:lang] = lang unless lang.nil? || lang.empty?

              acc << title_main if title_main.has_key?(:value)
            end
          end
        end

        def title_sort
          lambda do |rec, acc|
            titles = []
            Traject::MarcExtractor.cached("245abfghknps").each_matching_line(rec) do |field, spec, extractor|
              title = title_value(field)
              non_filing = field.indicator2.to_i
              if title.length > non_filing
                title = title.slice(non_filing, title.length)
              end
              titles << title unless title.nil? || title.empty?
            end
            acc << titles.first
          end
        end

        def title_value(field)
          subfields = field.subfields.select { |sf| %w[a b f g h k n p s].include?(sf.code) }
          subfields.map do |sf|
            sf.code == 'h' ? extract_final_punct(sf.value) : sf.value
          end.compact.join(' ').gsub(/[\s,\/]*([\.;]?)$/, '\1')
        end

        def extract_final_punct(value)
          match = value.strip.match(/[[:punct:]]$/)
          match[0].gsub(']', '') unless match.nil?
        end
      end
    end
  end
end
