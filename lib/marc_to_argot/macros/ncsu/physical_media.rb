module MarcToArgot
  module Macros
    module NCSU
      # mapping of physical media types based on item type
      module PhysicalMedia
        def type_map
          @type_map ||= Traject::TranslationMap.new('ncsu/item_type_to_pm')
        end

        def physical_media
          # physical media type based on item type with one
          # small twist
          lambda do |_rec, acc, ctx|
            physical_items = ctx.clipboard.fetch('items', []).reject { |i|
              i['loc_b'] == 'ONLINE'
            }
            types = physical_items.map do |i|
              # EBOOK at DHHILL means E-reader, elsewhere means 'electronic book
              i['type']
            end.select(&:itself)
            types.each do |t|
              t = type_map[t]
              acc << t if t
            end
            acc.uniq!
            acc << 'Print' if (acc.empty? && !physical_items.empty?)
          end
        end
      end
    end
  end
end
