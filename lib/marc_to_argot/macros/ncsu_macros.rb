module MarcToArgot
  module Macros
    # Macros for NCSU-specific tasks
    module NCSU
      MarcExtractor = Traject::MarcExtractor
      include Traject::Macros::Marc21Semantics

      def ncsu_rollup_id
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
    end
  end
end
