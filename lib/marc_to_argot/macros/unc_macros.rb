module MarcToArgot
  module Macros
    # Macros and useful functions for UNC records
    module UNC
      MarcExtractor = Traject::MarcExtractor
      include Traject::Macros::Marc21Semantics
      include MarcToArgot::Macros::Shared
      
      # tests whether the record has any physical items
      # this implementation asks whether there are any 999 fields that:
      #  - have i1=9 (in all records, dates are output to 999 w/i1=0), and
      #  - have i2<3 (i.e. an unsuppressed item or holding record exists)
      # Records with ONLY an order record will NOT be assigned an
      #  access_type value, given that it is presumed the item is on order
      #  and not at all accessible yet.
      # @param rec [MARC::Record] the record to be checked.
      # @param _ctx [Object] extra context or data to be used in the test
      #   (for overrides)
      def physical_access?(rec, _ctx = {})
        checkfields = []
        rec.each_by_tag('999') { |f| checkfields << f if f.indicator1 == '9' && f.indicator2.to_i < 3}
        if checkfields.size > 0
          return true
        else
          return false
        end
      end

      

      def url
        url_extor = MarcExtractor.cached('856uy3')
        lambda do |rec, acc, _|
          urls = []
          url_extor.each_matching_line(rec) do |field, spec, extractor|
            url = {}
            text = []
            text3 = []
            rel = ''
            href = []

            field.subfields.each do |sf|
              val = sf.value.strip
              case sf.code
              when 'u'
                href << val
              when 'y'
                text << val
              when '3'
                text3 << val.sub(/ ?\W* ?$/, '')
                rel = 'thumbnail' if val.downcase.include?('thumbnail')
                rel = 'findingaid' if val.downcase.include?('finding aid')
              end
            end

            url['href'] = href.first unless href.empty?

            case field.indicator2.to_i
            when 0
              rel = 'fulltext'
            when 1
              rel = 'fulltext'
            when 2
              rel = 'related' if rel.empty?
            else
              rel = 'other'
            end

            # don't need this delimiter unless both text and text3 are populated
            text << 'Available via the UNC-Chapel Hill Libraries' if text.empty? && rel == 'fulltext'
            text3 << '--' unless text3.empty? || text.empty?
            finaltext = text3 + text
            url['text'] = finaltext.join(' ')
            url['rel'] = rel
            urls << url unless href.empty?
          end
          urls.each { |u| acc << u } unless urls.empty?
        end
      end
      
    end
  end
end
