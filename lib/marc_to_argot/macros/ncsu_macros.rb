

module MarcToArgot
  module Macros
    # Macros for NCSU-specific tasks
    module NCSU
      autoload :Summaries, 'marc_to_argot/macros/ncsu/summaries'
      autoload :Items, 'marc_to_argot/macros/ncsu/items'

      include MarcToArgot::Macros::NCSU::Summaries
      include MarcToArgot::Macros::NCSU::Items

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

      def generate_holdings(items)
        holdings = []
        lib_group = items.group_by { |x| x['loc_b'] }
        lib_group.collect do |lib, libitems|
          libitems.group_by { |x| x['loc_n'] }.each do |loc_n, itemz|
            cns = itemz.collect { |x| x['call_no'] }
            holdings << { 'loc_b' => lib, 'loc_n' => loc_n }.merge(summary(cns))
          end
        end
        holdings
      end
    end
  end
end
