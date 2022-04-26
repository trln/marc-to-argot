

module MarcToArgot
  module Macros
    # Macros for NCSU-specific tasks
    module NCSU
      require 'marc_to_argot/macros/ncsu/summaries'
      require 'marc_to_argot/macros/ncsu/item_utils'
      require 'marc_to_argot/macros/ncsu/items'
      require 'marc_to_argot/macros/ncsu/physical_media'
      require 'marc_to_argot/macros/ncsu/resource_type'
	    require 'marc_to_argot/macros/ncsu/shared_records'
      require 'marc_to_argot/macros/ncsu/issns'

      include Traject::Macros::Marc21Semantics
      include MarcToArgot::Macros::Shared

      include Summaries
      include Items
      include PhysicalMedia
      include SharedRecords
      include ISSNS

      MarcExtractor = Traject::MarcExtractor

      # Sets the list of MARC org codes that are local.
      # Used by #subfield_5_present_with_local_code?
      def local_marc_org_codes
        %w[NcRS NcRS-P NcRS-V NcRhSUS]
      end

      # Donor field is computed from 710 (any indicators) where $3
      # is 'Donor'.  It is used in NCSU frontend to compute filenames
      # for bookplate images.
      def donor
        extor = MarcExtractor.cached('710')
        lambda do |rec, acc|
          donors = extor.each_matching_line(rec) do |f|
            acc << f['a'] if f['3'] == 'Endow'
          end
        end
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

      def url
        lambda do |rec, acc|
          Traject::MarcExtractor.cached("856uyz3").each_matching_line(rec) do |field, spec, extractor|
            url = {}
            url[:href] = url_href_value(field)

            next if url[:href].nil? || url[:href].empty?

            url[:type] = url_type_value(field)
            url[:text] = url_text(field) unless url_text(field).empty?
            url[:note] = url_note(field) unless url_note(field).empty?

            acc << url.to_json
          end
        end
      end

      # @param field [MARC::DataField] the field to use to assemble URL note
      def url_note(field)
        subfield_values = collect_subfield_values_by_code(field, '3')
        subfield_values += collect_subfield_values_by_code(field, 'z')
        subfield_values.reject(&:empty?).join('; ')
      end

      def open_access!(urls, items)
        if items.any? { |i| i['loc_b'] == 'ONLINE' && i['item_cat_2'] == 'OPENACCESS' }
          urls.select{ |u| u['type'] == 'fulltext'}.each{ |u| u['restricted'] = false}         
        end
      end

      def local?(ctx)
        ctx.output_hash['institution'] == ['ncsu']
      end

      def is_available?(items)
        items.any? { |i| i.fetch('status', '').match?(/^avail/i) || i['loc_b'] == 'ONLINE' }
      end

      def online_access?(_rec, libraries = [])
        libraries.include?('ONLINE')
      end

      def url_for_finding_aid?(fld)
        substring_present_in_subfield?(fld, 'u', 'www.lib.ncsu.edu/findingaids')
      end

	  def process_shared_records!(rec, ctx, urls)
	    set_shared_records!(rec, ctx)
		return unless ctx.clipboard[:shared_record_set] == 'nclive'
		ctx.output_hash["record_data_source"] = ["ILSMARC" , "Shared Records" , "NCLIVE"]
	    ctx.output_hash["virtual_collection"] = ["TRLN Shared Records. NC LIVE videos."]
		ctx.output_hash["institution"] = %w[duke nccu ncsu unc]
		urls.select {|u| u["type"]== "fulltext"}.each do |u|
          u["href"] = '{+proxyPrefix}' + u["href"] unless u["href"].match?(/^{\+proxyPrefix}/)
		end
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
