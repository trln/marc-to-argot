# coding: utf-8

require_relative './names'

module MarcToArgot
  module Macros
    module Shared
      module CreatorMain
        include MarcToArgot::Macros::Shared::Names
        
        def creator_main
          lambda do |rec, acc|
            creators = []
            
            Traject::MarcExtractor.cached('100:110:111')
                                  .each_matching_line(rec) do |field, spec, extractor|

              next unless subfield_5_absent_or_present_with_local_code?(field)
              creators << get_creator(field)
            end
            acc << creators.reverse.join(' / ')
            acc.compact!
            acc.reject! { |e| e == '' }
          end
        end

        def get_creator(field)
          name_part = names_name(field)
          rel_part = names_rel(field)

          if rel_part.length > 0
            name_part << ', ' unless name_part.end_with?('-')
          end
          
          name_part + rel_part.join(', ')
        end
        
      end
    end
  end
end
