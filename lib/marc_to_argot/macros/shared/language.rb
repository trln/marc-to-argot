module MarcToArgot
  module Macros
    module Shared
      module Language

        LANG_MAP = Traject::TranslationMap.new('shared/marc_languages')
        KEEP_041_SUBFIELDS = 'adeg'

        # accumulates an array of JSON blobs with URL data from a record.
        def language
          lambda do |rec, acc|
            lang_codes = []

            lang_codes << get_008_lang_code(rec)
            lang_codes << get_041_lang_codes(rec) if field_present?(rec, '041')

            langs = translate_codes(lang_codes.flatten.compact.uniq) unless lang_codes.empty?
            langs.each{ |lang| acc << lang } unless langs.empty?
          end
        end

        # Given a MARC::Record
        # Returns the 008/35-37 value [String] if there is an 008 with those byte positions
        # Else returns nil
        def get_008_lang_code(rec)
          rec['008'].value[35, 3] if rec['008']
        end

        def get_041_lang_codes(rec)
          codes = []

          fields = rec.fields.select{ |f| f.tag == '041' }.reject{ |f| f.indicator2 == '7' }

          fields.each do |field|
            if is_translation?(field)
              codes << get_translation_lang_codes(field)
            else
              codes << get_non_translation_lang_codes(field) unless is_translation?(field)
            end
          end

          codes.flatten unless codes.empty?
        end

        def keep_041_subfields(field)
          field.subfields.select{ |sf| KEEP_041_SUBFIELDS.include?(sf.code) }
        end

        def get_non_translation_lang_codes(field)
          codes = []
          keep_041_subfields(field).each do |sf|
            if good_041_code_length?(sf.value)
              if sf.value.length == 3
                codes << sf.value
              else
                codes << sf.value.scan(/.../)
              end
            end
          end
          return codes.flatten.uniq unless codes.empty?
        end

        def get_translation_lang_codes(field)
          codes = []
          keep_041_subfields(field).each do |sf|
            if good_041_code_length?(sf.value)
              if sf.value.length == 3
                codes << sf.value
              else
                codes << sf.value.scan(/.../) if has_non_a_041_subfields?(field) == true
                codes << sf.value.scan(/.../).first if has_non_a_041_subfields?(field) == false
              end
            end
          end
          return codes.flatten.uniq unless codes.empty?
        end

        def has_non_a_041_subfields?(field)
          gather_sfs = KEEP_041_SUBFIELDS.chars.reject{ |e| e == 'a' }
          all_sfs = subfields_present(field)
          result = gather_sfs & all_sfs
          return true unless result.empty?
          false
        end

        def is_translation?(field)
          return false if field.indicator1 == '0'
          true
        end

        # Given the value of a subfield [String]
        # Returns true if length of value is evenly divisible by 3
        # Otherwise, false
        def good_041_code_length?(value)
          return false if value.length == 0
          return true if value.length % 3 == 0
          false
        end


        # Given [Array] of MARC language codes
        # Returns [Array] of human readable language names
        def translate_codes(codes)
          LANG_MAP.translate_array!(codes)
        end
      end
    end
  end
end

  # maps languages, by default out of 008[35-37] and 041a and 041d
  #
  # de-dups values so you don't get the same one twice.
  #
  # Note: major issue with legacy marc records
  #   Legacy records would jam all langs into 041 indicator1
  #   E.g., an material translated from latin -> french -> english, would have all
  #   3 languages in 041a, though the material may not have any french text
  #
  #   To remedy, any 041a indicator 1, with a value of 6 or more
  #   alpha characters will be thrown out

  # def argot_languages(spec = "008[35-37]:041adeg")
  #   translation_map = Traject::TranslationMap.new("marc_languages")

  #   extractor = MarcExtractor.new(spec, :separator => nil)

  #   lambda do |record, accumulator|
  #     codes = extractor.collect_matching_lines(record) do |field, spec, extractor|
  #       if extractor.control_field?(field)
  #         (spec.bytes ? field.value.byteslice(spec.bytes) : field.value)
  #       else
  #         #get all potentially usable subfields
  #         subfields = field.subfields.collect do |sf|
  #           sf if spec.includes_subfield_code?(sf.code)
  #         end.compact
  #         #reject $a of translations with multiple languages crammed into $a
  #         good_subfields = subfields.reject { |sf| field.indicator1 == '1' && sf.code == 'a' && sf.value.length >=6 }
  #         good_subfields.collect do |sf|
  #           if sf.value.length == 3
  #             value = sf.value
  #           elsif
  #           else
  #             value = sf.value.chars.each_slice(3).map(&:join)
  #           end
  #           value
  #         end.flatten
  #       end
  #     end
  #     codes = codes.uniq

  #     translation_map.translate_array!(codes)

  #     accumulator.concat codes
  #   end
  # end
