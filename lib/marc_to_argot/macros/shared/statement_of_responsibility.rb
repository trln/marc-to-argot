module MarcToArgot
  module Macros
    module Shared
      module StatementOfResponsibility
        def statement_of_responsibility
          lambda do |rec, acc|
            sor = get_sor_from_245(rec, :alternate_script => true)
            sor.each { |s| acc << s } unless sor.nil? || sor.empty?
            acc.uniq!
          end
        end

        def get_sor_from_245(rec, options)
          sors = []
          Traject::MarcExtractor.cached('245c').each_matching_line(rec) do |field, spec, extractor|
            value = collect_and_join_subfield_values(field, 'c', ' ')
            lang = Vernacular::ScriptClassifier.new(field, value).classify
            sor = {}
            sor['value'] = value unless value.nil? || value.empty?
            sor['lang'] = lang unless lang.nil? || lang.empty?
            sors << sor if sor.has_key?('value')
          end
          return sors unless sors.empty?
        end
      end
    end
  end
end
