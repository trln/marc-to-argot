module MarcToArgot
  module Macros
    module Duke
      module ResourceType
        class Shared::PhysicalMedia::PhysicalMediaClassifier
          # Checks the 940$c for any cases where the narrow location
          # includes an ebook location code. See #ebook_location_codes below.
          def e_reader?
            item_fields(record).find do |field|
              field.subfields.select { |sf| sf.code == 'c' }.find { |sfc| ebook_location_codes.include?(sfc.value) }
            end
          end

          # Checks the 940$h for call numbers that include the
          # substring "kindle."
          def e_reader_kindle?
            item_fields(record).find do |field|
              field.subfields.select { |sf| sf.code == 'h' }.find { |sfc| sfc.value.downcase.include?('kindle') }
            end
          end

          def item_fields(record)
            @item_fields ||= begin
              item_fields = []
              Traject::MarcExtractor.cached('940', alternate_script: false).each_matching_line(record) do |field|
                item_fields << field
              end
              item_fields
            end
          end

          def ebook_location_codes
            %w[DKK FRDK1 FRDK2 FRDK3 PDK PKKI PKKR PKKZ
               PKXKR PLK1 PLK2 PLKR PLXKR PZK1 PZK2]
          end
        end
      end
    end
  end
end
