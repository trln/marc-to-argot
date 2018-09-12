

module MarcToArgot
  module Macros
    # Macros for NCSU-specific tasks
    module NCSU
      require 'marc_to_argot/macros/ncsu/summaries'
      require 'marc_to_argot/macros/ncsu/items'
      require 'marc_to_argot/macros/ncsu/physical_media'
      require 'marc_to_argot/macros/ncsu/resource_type'

      include Traject::Macros::Marc21Semantics
      include MarcToArgot::Macros::Shared

      include Summaries
      include Items
      include PhysicalMedia

      MarcExtractor = Traject::MarcExtractor

      # Sets the list of MARC org codes that are local.
      # Used by #subfield_5_present_with_local_code?
      def local_marc_org_codes
        %w[NcRS NcRS-P NcRS-V NcRhSUS]
      end

      def resource_type
        lambda do |rec, acc, ctx|
          acc << MarcToArgot::Macros::NCSU::ResourceType.classify(rec, ctx.clipboard['items'])
          acc.flatten!
        end
      end

      # tests whether the record is a serial of the sort E-Matrix trades in.
      def serial?(rec)
        rec.leader.byteslice(7) == 's' and ['p', 'm', 'n', ' '].include?(rec['008'].value.byteslice(21))
      rescue StandardError
        false
      end

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
          acc.compact!
          acc.reject!(&:empty?)
          acc.uniq!
          acc.map! { |x| "OCLC#{x}" }
        end
      end

      def is_available?(items)
        items.any? { |i| i['status'] =~ /^avail/i || i['loc_b'] == 'ONLINE' }
      end

      def online_access?(_rec, libraries = [])
        libraries.include?('ONLINE')
      end

      def url_for_finding_aid?(fld)
        substring_present_in_subfield?(fld, 'u', 'www.lib.ncsu.edu/findingaids')
      end

      # checks whether there are any physical items;
      # this implementation looks at whether there are any
      # items in a library other than ONLINE
      def physical_access?(_rec, libraries = [])
        libraries.any? { |x| x != 'ONLINE' }
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
