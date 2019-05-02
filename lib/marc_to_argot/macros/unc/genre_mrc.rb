module MarcToArgot
  module Macros
    module UNC
      module GenreMrc

        # If record is part of a shared record set, set the code for the set
        # Further processing is based on this code value
        def set_shared_record_set_code(rec, cxt)
          shared_set = nil
          Traject::MarcExtractor.cached('919|  |a', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
            value = field.to_s.downcase
            case value
            when /asp/
              cxt.clipboard[:shared_record_set] = 'asp'
            when /dwsgpo/
              cxt.clipboard[:shared_record_set] = 'dws'
            when /troup/
              cxt.clipboard[:shared_record_set] = 'oupp'
            end
          end
          
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
