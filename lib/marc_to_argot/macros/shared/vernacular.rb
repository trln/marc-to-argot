module MarcToArgot
  module Macros
    module Shared
      module Vernacular

        def basic_vernacular_field(spec, options={})
          lambda do |rec, acc|
            Traject::MarcExtractor.cached(spec, options).each_matching_line(rec) do |field, spec, extractor|
              values = extractor.collect_subfields(field, spec)
              values.each do |value|
                field_values = {}

                lang = Vernacular::ScriptClassifier.new(field, value).classify

                value = Traject::Macros::Marc21.trim_punctuation(value) if options.fetch(:trim_punctuation, nil) == true

                field_values['value'] = value unless value.nil? || value.empty?
                field_values['lang'] = lang unless lang.nil? || lang.empty?

                acc << field_values if field_values.has_key?('value')
              end
            end
          end
        end

        class ScriptClassifier
          attr_reader :field
          attr_reader :value

          def initialize(field, value)
            @field = field
            @value = value.to_s
          end

          def classify
            case
            when is_cjk?
              'cjk'
            when is_cyrillic?
              'rus'
            when is_arabic?
              'ara'
            end
          end

          def is_cjk?
            classifier(cjk_matcher)
          end

          def is_cyrillic?
            classifier(cyrillic_matcher)
          end

          def is_arabic?
            classifier(arabic_matcher)
          end

          private

          def classifier(pattern)
            char_pattern_match_count = value.scan(pattern).length
            return true if char_pattern_match_count > 0 && field.tag == '880'
            return true if (char_pattern_match_count.to_f / value.length) > 0.1
          end

          def cjk_matcher
            /\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/
          end

          def cyrillic_matcher
            /\p{Cyrillic}/
          end

          def arabic_matcher
            /\p{Arabic}/
          end
        end
      end
    end
  end
end
