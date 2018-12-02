require 'active_support'

module MarcToArgot
  module Macros
    module Shared
      # Macros and methods for working with titles.
      module Title
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

        # extracts a short title from title_main (if appropriate)
        # @param [Fixnum] max_length the maximum word length in a title
        # that will be extracted.
        # NOTE: this lambda assumes that title_main will already be populated,
        # in the output hash, so this macro should only be invoked after
        # #title_main
        def short_title(max_length = 4)
          lambda do |_, acc, ctx|
            output_hash = ctx.output_hash
            main_title = output_hash.fetch('title_main', '')
            return if main_title.empty?

            words = main_title.first[:value].split(/\s+/)
            if words.length <= max_length
              # strip any punctuation off the last word
              words[-1] = words[-1].gsub(/[^a-z0-9]$/i, '')
              acc << words.join(' ')
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
              titles << normalize_string_for_sorting(title) unless title.nil? || title.empty?
            end
            acc << titles.reverse.join(' ')
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

        def normalize_string_for_sorting(str)
          # Apply NFKD normalization to the string.
          # See: http://www.unicode.org/reports/tr15/tr15-29.html
          kd = ActiveSupport::Multibyte::Chars.new(str).downcase.normalize(:kd)
          # Select the codepoints that are not combining diacritics.
          codepoints = kd.codepoints.select { |c| c < 0x0300 || c > 0x036F }
          # Convert the Unicode codepoints back to a string.
          normed = codepoints.pack("U*")
          # Replace '&' with 'and'
          normed.gsub!(' & ', ' and ')
          # Replace common ligatures
          normed.gsub!('æ','ae')
          normed.gsub!('œ', 'oe')
          # Replace hyphens, dashes, slashes with a space.
          # See: https://www.niso.org/sites/default/files/2017-08/tr03.pdf
          normed.gsub!(/[\-—\\\/]/,   ' ')
          # Remove other punctuation marks
          normed.gsub!(/[[:punct:]]/, '')
          # Replace two or more spaces with a single space.
          normed.gsub!(/\s{2,}/, ' ')
          # Remove any leading or trailing whitespace.
          normed.strip
        end
      end
    end
  end
end
