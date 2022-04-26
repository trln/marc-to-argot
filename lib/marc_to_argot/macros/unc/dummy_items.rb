module MarcToArgot
  module Macros
    module UNC
      module DummyItems

        def dummy_items(rec, cxt)
          items = []

          orders = get_orders(rec)
          orders.each { |o| items << item_from_order(o) } if orders

          items << item_from_nothing if items.length == 0
          
          items = items.map{ |i| i.to_json }
          
          cxt.output_hash['items'] = items if items.length > 0
       end

        def get_orders(rec)
          orders = rec.fields.select{ |f| f.tag == '999' &&
                                      f.indicator1 == '9' &&
                                      f.indicator2 == '4' &&
                                      f['b'] != 'n' &&
                                      f['g'] != 'z' }
          return orders if orders.length > 0
        end

        def item_from_order(field)
          item = {}
          field.subfields.each do |sf|
            code = sf.code
            value = sf.value
            case code
            when 'f'
              item['loc_b'] = value
              item['loc_n'] = value
            end
            item['status'] = 'On Order'
          end
          item
        end
          
        def item_from_nothing
          {'loc_b' => 'unknown',
           'loc_n' => 'unknown',
           'status' => 'Contact Library for Status',
           'notes' => ['Ask at Library Service Desk']
          }
        end

      end
    end
  end
end
