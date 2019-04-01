module MarcToArgot
  module Macros
    module Duke
      module ResourceType
        class Shared::ResourceType::ResourceTypeClassifier
          def thesis_dissertation?
            record.fields('942').find do |field|
              field.subfields.select { |sf| sf.code == 'b' }
                             .find { |sfc| sfc.value.downcase.include?('duke theses') }
            end
          end
        end
      end
    end
  end
end
