module MarcToArgot
  module Macros
    module UNC
      module SharedRecords

        # shared record sets that include print/physical items
        PHYSICAL_SETS = ['oupp']

        # If record is part of a shared record set, set the code for the set
        # Further processing is based on this code value
        #
        # This should be limited to sets of records that are shared with at
        # least one other TRLN institution. It is not a good means to add
        # a virtual collection field to local UNC records; shared record
        # set processing can have side effects not appropriate for local
        # records.
        def id_shared_record_set(rec)
          shared_set = nil
          Traject::MarcExtractor.cached('919|  |a:773|0 |t', alternate_script: false).each_matching_line(rec) do |field, _spec, _extractor|
            value = field.value.downcase
            case value
            when 'dwsgpo'
              shared_set = 'dws'
            when 'troup'
              shared_set = 'oupp'
            when /^center for research libraries \(crl\) eresources \(online collection\)/
              shared_set = 'crl'
            end
          end
          shared_set
        end

        def shared_physical?(shared)
          PHYSICAL_SETS.include?(shared)
        end

        def add_institutions(cxt, institution_array)
          institution_array.each { |i| cxt.output_hash['institution'] << i }
        end

        def add_record_data_source(cxt, value)
          cxt.output_hash['record_data_source'] << value
        end

        def add_virtual_collection(cxt, value)
          if cxt.output_hash['virtual_collection']
            cxt.output_hash['virtual_collection'] << value
          else
            cxt.output_hash['virtual_collection'] = [value]
          end
        end
      end
    end
  end
end
