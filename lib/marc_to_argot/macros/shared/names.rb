module MarcToArgot
  module Macros
    module Shared
      module Names
        ################################################
        # Names Macros
        ######

        def names
          lambda do |rec, acc, ctx|
            Traject::MarcExtractor.cached('100:110:111:700:710:711:720', :alternate_script => false)
                                  .each_matching_line(rec) do |field, spec, extractor|

              next unless passes_names_constraint?(field)
              next unless subfield_5_absent_or_present_with_local_code?(field)
              Logging.mdc['field'] = field.tag
              names = assemble_names_hash(field)

              acc << names unless names.empty?
              Logging.mdc.delete('field')
            end
          end
        end

        def assemble_names_hash(field)
          name = {}

          name['name'] = names_name(field)
          name['rel'] = names_rel(field)
          name['type'] = names_type(field, name['rel'])

          name.delete_if { |k, v| v.nil? || v.empty? }
        end

        def names_name(field)
          
          name = ''
          case field.tag
          when /(100|700)/
            name = collect_and_join_subfield_values(field, %w[a b c d g j q u])
          when /(110|710)/
            name = collect_and_join_subfield_values(field, %w[a b c d g n u])
          when /(111|711)/
            name = collect_and_join_subfield_values(field, %w[a c d e g n q u])
          when '720'
            name = collect_and_join_subfield_values(field, 'a')
          end

          name.gsub(/(?<!\s[A-Z])[\.,]\s?$/, '').strip
        end

        def names_rel(field)
          rels = []
          rels.concat names_collect_rels(field, '4').map { |code| names_map_relator_code_to_term(code) }
          case field.tag
          when /(100|110|700|710|720)/
            rels.concat names_collect_rels(field, 'e')
          when /(111|711)/
            rels.concat names_collect_rels(field, 'j')
          end
          rels.compact.map(&:downcase).uniq
        end

        def names_map_relator_code_to_term(code)
          term = relator_code_to_term[code]
          logger.warn "Relator code '#{code}' not mapped to a relator term." if term.nil?
          term
        end

        def names_collect_rels(field, codes)
          collect_subfield_values_by_code(field, codes).map { |v| names_cleanup_rels(v) }
        end

        def names_cleanup_rels(value)
          # remove FRBR/WEMI terms sometimes found in relators
          value = value.gsub(/\((work|expression|manifestation|item)\)/i, '').strip
          # remove instution/library-specific relator qualifiers
          value = value.gsub(/\((ncc|rbc).*\)/i, '').strip
          # cleanup punctuation and spacing
          value = value.gsub(/(?<!etc)[,\.\s]*$/, '').gsub(/^([,\.\s])*/, '').strip
        end

        def names_type(field, rels)
          return name_type_with_rel(rels) unless rels.empty?
          case field.tag
          when /(100|110|111)/
            'creator'
          when /(700|710|711|720)/
            'no_rel'
          end
        end

        def name_type_with_rel(rels)
          type = rels.map do |rel|
            category = relator_categories[rel]
            if category.nil?
              not_standard = true
              category = relator_categories_local[rel]
            end
            logger.warn "Non-standard relator term '#{rel}' not mapped to a relator category." if category.nil?
            logger.warn "Relator term '#{rel}' not a standard relator term, but was mapped to a relator category." if not_standard && category
            category
          end
          type = (names_category_order & type).first
          type.nil? ? 'uncategorized' : type
        end

        def relator_code_to_term
          @relator_code_to_term ||= Traject::TranslationMap.new('shared/relator_code_to_term')
        end

        def relator_categories
          @relator_categories ||= Traject::TranslationMap.new('shared/relator_categories')
        end

        def relator_categories_local
          @relator_categorial ||= Traject::TranslationMap.new('shared/relator_categories_local')
        end

        def names_category_order
          %w[director
             creator
             editor
             contributor
             no_rel
             owner
             other
             uncategorized
             publisher
             manufacturer
             distributor]
        end

        def passes_names_constraint?(field)
          case field.tag
          when /(700|710|711)/
            !(%w[t k] & field.subfields.map(&:code)).any?
          else
            true
          end
        end
      end
    end
  end
end
