module MarcToArgot
  module Macros
    module Duke
      module SharedRecords
        # If record is part of a shared record set, set the code for the set
        # Further processing is based on this code value
        def set_shared_record_set_code(rec, ctx)
          Traject::MarcExtractor.cached('915a', alternate_script: false)
                                .each_matching_line(rec) do |field, spec, extractor|
            case field.value.downcase
            when 'university press scholarship online - frontfile'
              ctx.clipboard[:shared_record_set] = 'oupe'
            end
          end
        end

        def add_shared_record_data(ctx)
          return unless ctx.clipboard.fetch(:shared_record_set, false)
          case ctx.clipboard.fetch(:shared_record_set, false)
          when 'oupe'
            ctx.output_hash['virtual_collection'] ||= []
            ctx.output_hash['record_data_source'] ||= []
            ctx.output_hash['institution'] = %w[duke unc ncsu nccu]
            ctx.output_hash['virtual_collection'] <<
              'TRLN Shared Records. Oxford University Press online titles.'
            ctx.output_hash['record_data_source'].concat(['Shared Records', 'OUPE'])
            ctx.output_hash.delete('location_hierarchy')
          end
        end
      end
    end
  end
end
