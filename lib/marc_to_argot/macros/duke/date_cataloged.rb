# frozen_string_literal: true

module MarcToArgot
  module Macros
    module Duke
      class MyParserError < StandardError
      end

      # DateCataloged determine the appropriate 'date_cataloged' value
      # for a given record based on the following criteria:
      # - first, attempt to find physical item date (914d)
      # - next, find e-resource date
      # - finally, as a fallback, use legacy receiving date
      module DateCataloged
        def date_cataloged
          lambda do |rec, acc|
            # physical items
            d = physical_item_date(rec)
            acc << d && return unless d.nil?

            d = eresource_item_date(rec)
            acc << d && return unless d.nil?

            # receiving date (legacy fallback)
            d = receiving_date(rec)
            acc << d && return unless d.nil?
          end
        end

        def physical_item_date(rec)
          dates_914d = Traject::MarcExtractor.cached('914d', alternate_script: false)
                                             .extract(rec)
                                             .map { |d| Time.strptime(d, '%Y%m%d') }
                                             .sort
          Time.parse(dates_914d.first.to_s.strip).utc.iso8601 unless dates_914d.empty?
        rescue ArgumentError => e
          logger.warn("date_cataloged (physical item) value cannot be parsed: #{e}")
          nil
        end

        def eresource_item_date(rec)
          dates_943n = Traject::MarcExtractor.cached('943n', alternate_script: false)
                                             .extract(rec)
                                             .sort_by { |w| Time.parse(w) }
          Time.parse(dates_943n.first.to_s.strip).utc.iso8601 unless dates_943n.empty?
        rescue ArgumentError => e
          logger.warn("date_cataloged (e-resource) value cannot be parsed: #{e}")
          # return nil so the we can look for the fallback date
          nil
        end

        def receiving_date(rec)
          dates_940f = Traject::MarcExtractor.cached('940f', alternate_script: false)
                                             .extract(rec)
                                             .sort_by { |w| Time.parse(w) }
          Time.parse(dates_940f.first.to_s.strip).utc.iso8601 unless dates_940f.empty?
        rescue ArgumentError => e
          logger.warn("date_cataloged (receiving date) value cannot be parsed: #{e}")
          # return nil so no date returns at all
          nil
        end
      end
    end
  end
end
