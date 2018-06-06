module MarcToArgot
  module Macros
    module Shared
      module PhysicalDescription
        ################################################################
        # Physical Description Macros
        ################################################################

        def physical_description
          lambda do |rec, acc|
            Traject::MarcExtractor.cached('300', :alternate_script => false)
                                  .each_matching_line(rec) do |field, spec, extractor|

              description = {}

              description['label'] = collect_and_join_subfield_values(field, '3').chomp(':').strip
              description['value'] = collect_and_join_subfield_values(field, %w[a b c e f g])

              description.delete_if { |k, v| v.nil? || v.empty? }

              acc << description unless description.empty?
            end
          end
        end

        def physical_description_details
          lambda do |rec, acc|
            Traject::MarcExtractor.cached('340:344:345:346:347:352', :alternate_script => false)
                                  .each_matching_line(rec) do |field, spec, extractor|

              case field.tag
              when '340'
                descriptions = assemble_physical_description_hash(field, %w[a b c d e f g h i j k m n o])
              when '344'
                descriptions = assemble_physical_description_hash(field, %w[a b c d e f g h])
              when '345'
                descriptions = assemble_physical_description_hash(field, %w[a b])
              when '346'
                descriptions = assemble_physical_description_hash(field, %w[a b])
              when '347'
                descriptions = assemble_physical_description_hash(field, %w[a b c d e f])
              when '352'
                description = {}
                description['label'] = 'Data set graphics details'
                description['value'] = collect_and_join_subfield_values(field, %w[a b c d e f g i q])
                descriptions = [description]
              end

              acc.concat descriptions if descriptions
            end
          end
        end

        def assemble_physical_description_hash(field, sf_codes)
          descriptions = sf_codes.map do |sf_code|
            description = {}
            value = collect_and_join_subfield_values(field, sf_code, '; ')
            unless value.nil? || value.empty?
              description['label'] = physical_description_details_label(field, sf_code)
              description['value'] = value
            end
            description
          end
          descriptions.delete_if { |d| d.empty? }
        end

        def physical_description_details_label(field, sf_code)
          labels = []
          labels << capitalize_first_letter(collect_and_join_subfield_values(field, '3').chomp(':').strip)
          case field.tag
          when '340'
            labels << physical_description_details_label_340(sf_code)
          when '344'
            labels << physical_description_details_label_344(sf_code)
          when '345'
            labels << physical_description_details_label_345(sf_code)
          when '346'
            labels << physical_description_details_label_346(sf_code)
          when '347'
            labels << physical_description_details_label_347(sf_code)
          end
          labels.delete_if { |l| l.nil? || l.empty? }.compact.join(': ')
        end

        def physical_description_details_label_340(sf_code)
          case sf_code
          when 'a'
            'Base/substrate material'
          when 'b'
            'Dimensions'
          when 'c'
            'Medium'
          when 'd'
            'Technique'
          when 'e'
            'Support material'
          when 'f'
            'Production rate/ratio'
          when 'g'
            'Color characteristics'
          when 'h'
            'Found in/on'
          when 'i'
            'Use requires'
          when 'j'
            'Generation of reproduction'
          when 'k'
            'Layout'
          when 'm'
            'Book format'
          when 'n'
            'Font size'
          when 'o'
            'Polarity'
          end
        end

        def physical_description_details_label_344(sf_code)
          case sf_code
          when 'a'
            'Recording type'
          when 'b'
            'Recording medium'
          when 'c'
            'Speed'
          when 'd'
            'Groove'
          when 'e'
            'Sound track configuration'
          when 'f'
            'Tape type'
          when 'g'
            'Channels'
          when 'h'
            'Special audio characteristics'
          end
        end

        def physical_description_details_label_345(sf_code)
          case sf_code
          when 'a'
            'Presentation format'
          when 'b'
            'Projection speed'
          end
        end

        def physical_description_details_label_346(sf_code)
          case sf_code
          when 'a'
            'Video format'
          when 'b'
            'Broadcast standard'
          end
        end

        def physical_description_details_label_347(sf_code)
          case sf_code
          when 'a'
            'File type'
          when 'b'
            'File format'
          when 'c'
            'File size'
          when 'd'
            'Image resolution'
          when 'e'
            'Regional encoding'
          when 'f'
            'Bitrate'
          end
        end
      end
    end
  end
end
