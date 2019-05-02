module MarcToArgot
  module Macros
    module Shared
      module PlaceOfOrigin
        ################################################################
        # resource type macros
        ################################################################

        def place_of_origin
          lambda do |rec, acc|
            acc.concat PlaceOfOriginSetter.new(rec).get_places
          end
        end

        class PlaceOfOriginSetter
          attr_reader :rec
          attr_reader :fields

          def initialize(rec)
            @rec = rec
            @fields = @rec.tags
          end

          def get_places
            places = []

            places << get_place_from_752 if @fields.include?('752')

            final_places = collapse_place_values(places.flatten)
            
            final_places
          end

          def collapse_place_values(places)
            all_f = places.map { |place| place['facet'] }
            all_s = places.map { |place| place['search'] }

            s = all_s.uniq
            f = all_f.flatten.uniq

            [{ 'search' => s,
               'facet' => f }]
          end

          def get_place_from_752
            places = []
            Traject::MarcExtractor.cached('752').each_matching_line(rec) do |field, spec, extractor|
              keep_sfs = %w[a b c d f g h]
              sfs = field.subfields.map { |sf| sf if keep_sfs.include?(sf.code)}.compact
              sfs.each { |sf| sf.value = sf.value.strip.gsub(/ +/, ' ') }
              s_value = get_searchable_752(sfs)
              f_value = get_facetable_752(sfs)
              places << place_hash(s_value, f_value)
            end
            places
          end

          def get_searchable_752(sfs)
            values = sfs.map{ |sf| sf.value }
            values.join('--')
          end

          def get_facetable_752(sfs)
            sfs.each do |sf|
              sf.value = 'New York (State)' if sf.code == 'b' && sf.value == 'New York'
              sf.value = 'New York County (N.Y.)' if sf.code == 'c' && sf.value == 'New York'
              sf.value = 'New York (N.Y.)' if sf.code == 'd' && sf.value == 'New York'
            end
            values = sfs.map{ |sf| sf.value }.uniq
            if get_searchable_752(sfs) =~ /District of Columbia--Washington\.?/
              values.reject! { |v| v =~ /^Washington\.?/ }
              values << 'Washington (D.C.)'
            end
            values
          end

          def place_hash(s, f)
            { 'search' => s,
              'facet'  => f }
          end

        end

      end
    end
  end
end

