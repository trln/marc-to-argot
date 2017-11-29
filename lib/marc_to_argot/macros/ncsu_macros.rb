module MarcToArgot
  module Macros
    # Macros for NCSU-specific tasks
    module NCSU
      MarcExtractor = Traject::MarcExtractor
      include Traject::Macros::Marc21Semantics
      include MarcToArgot::Macros::Shared

      def rollup_id
        control_number_extor = MarcExtractor.cached('001')
        cni_extor = MarcExtractor.cached('003')
        lambda do |rec, acc, _|
          base = oclcnum.call(rec, acc)
          acc << base.first unless base.empty?
          if cni_extor.extract(rec).first == 'OCoLC'
            oclc = control_number_extor.extract(rec).first
            acc << oclc.gsub(/^\D*/, '') unless oclc.nil?
          end
          acc.uniq!
          acc.map! { |x| "OCLC#{x}" }
        end
      end

      def online_access?(_rec, libraries = [])
        libraries.include?('ONLINE')
      end

      # checks whether there are any physical items;
      # this implementation looks at whether there are any
      # items in a library other than ONLINE
      def physical_access?(_rec, libraries = [])
        !libraries.find { |x| x != 'ONLINE' }.nil?
      end
    end
  end
end
