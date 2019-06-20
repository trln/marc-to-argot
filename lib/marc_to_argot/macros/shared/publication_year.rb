module MarcToArgot
  module Macros
    module Shared
      module PublicationYear

        # Gets called from traject_config to populate the publication_year field
        # Uses following configuration parameters:
        #  min_year: earliest date we consider to be a usable publication date
        #    Defaults to 500.
        #  max_year: latest date we consider to be a usable publication date
        #    Defaults to current year, plus 6 (due to ridiculous publisher shenanigans)
        #  cont_pub_max_year: date to use for continuing resources when they 
        #  are otherwise found to set the publication date to 9999.
        #    Defaults to current year plus one.
        #    
        #  range_tolerance: Maximum range we think is informative enough to set a
        #    publication_year from.
        #    Default so 500, which basically just throws out dates where we only know
        #      which millennium: 1uuu, 2uuu
        def publication_year(options = {})
          min_year            = options[:min_year] || 500
          max_year            = options[:max_year] || (Time.new.year + 6)
          range_tolerance     = options[:range_tolerance] || 500
          # max year to show for continuing resources
          cont_pub_max_year   = options[:cont_pub_max_year] || Time.new().year + 1
          
          lambda do |rec, acc|
            ff_date_type = rec.date_type
            date = set_year_from_008(rec, ff_date_type, min_year, max_year, range_tolerance) if field_present?(rec, '008')
            date = set_year_from_varfield(rec, ff_date_type, min_year, max_year, range_tolerance) if date == nil
            date = cont_pub_max_year if date&.to_i == 9999
            acc << date if date
          end
        end

        # retrieves date from 008 if that field exists and data in it is usable
        def set_year_from_008(rec, ff_date_type, min, max, range_tolerance)
          ff_date1 = get_date(rec.date1, ff_date_type, min, max, 'fixed_field', range_tolerance)
          ff_date2 = get_date(rec.date2, ff_date_type, min, max, 'fixed_field', range_tolerance)

          case ff_date_type
          when 'b'
            year_found = nil
          when 'c'
            year_found = ff_date2
          when 'd'
            year_found = date2_accounting_for_date1_in_range(ff_date1, rec.date2, min, max)
          when 'e'
            year_found = ff_date1
          when 'i'
            year_found = ff_date1
          when 'k'
            year_found = ff_date1
          when 'm'
            year_found = choose_ff_date(ff_date2, ff_date1, false)
          when 'n'
            year_found = midpoint_or_usable(ff_date1, ff_date2)
          when 'p'
            year_found = choose_ff_date(ff_date2, ff_date1, false)
          when 'q'
            year_found = midpoint_or_usable(ff_date1, ff_date2)
          when 'r'
            year_found = choose_ff_date(ff_date2, ff_date1, false)
          when 's'
            year_found = ff_date1
          when 't'
            year_found = ff_date1
          when 'u'
            year_found = choose_ff_date(ff_date2, ff_date1, true)
          end
          return year_found
        end

        # Retrieves date from the 260 or 264 used as main_imprint if we can't get a usable date
        #  from 008
        def set_year_from_varfield(rec, ff_date_type, min, max, range_tolerance)
          imprint_fields = []
          Traject::MarcExtractor.cached("260:264").each_matching_line(rec) do |field, spec, extractor|
            imprint_fields << field
          end

          # Selects which 260/264 field to use with the same logic as we set the imprint_main field
          # THIS IS FROM THE IMPRINT MACRO
          main_imprint = select_main_imprint(imprint_fields) unless imprint_fields.empty?

          date_sf = main_imprint['c'] if main_imprint
          date = get_date(date_sf, ff_date_type, min, max, 'var_field', range_tolerance) if date_sf
          return date
        end

        # Given single date string from any source field plus other parameters, returns either:
        #  - usable date as integer; or
        #  - nil
        def get_date(string, ff_date_type, min, max, type, range_tolerance)
          the_date = string.strip

          # Extract 3-4 character strings beginning with digits and, sometimes, ending with -
          #  from varfield date strings
          date_matcher = the_date.scan(/\d{4}|\d-{2,3}|\d{2}-{1,2}|\d{3}-?/) if type == 'var_field'
          if date_matcher
            if %{c d m u}.include?(ff_date_type)
              the_date = date_matcher.last
            else
              the_date = date_matcher.first
            end
          end
          
          # convert to range based on date source
          # fixed field indicates range with u
          # var field uses -
          if is_range?(the_date, type)
            case type
            when 'fixed_field'
              to_replace = 'u'
            when 'var_field'
              to_replace = '-'
            end
            startdate = the_date.gsub(to_replace, '0').to_i
            enddate = the_date.gsub(to_replace, '9').to_i

            # 20uu is the only way to indicate sometime since 2000, but we don't
            #   know if it was 2000-2009 or 2010-2019.
            # However I'm making an assumption that anything we are recording in metadata that will
            #   be transformed by MARC-to-Argot will not be happening in 2075 or some other ridiculous
            #   point in the future.
            # So, change 2099 range end date to the current year at time of transformation
            enddate = Time.new.year if enddate == 2099

            # ranges of over a certain number of years are pretty uninformative, so discard them.
            usedate = (startdate + enddate)/2 if enddate - startdate <= range_tolerance
          else
            usedate = the_date.to_i
          end
          usedate = nil unless usable_date?(usedate, min, max)
          return usedate
        end

        # Determines whether a given date value represents a range
        #  e.g. 19uu, meaning 1900 to 1999
        # Fixed field dates represent ambiguous part of date with 'u'
        # Var field dates use '-'
        def is_range?(str, type)
          case type
          when 'fixed_field'
            return true if str =~ /\d+u+/
            false
          when 'var_field'
            return true if str =~ /\d+-+/
            false
          end
        end

        # Says whether it's a usable date, given our min and max date settings
        # 9999 is considered usable in general because it is a meaningful value in
        #  the 008 date2
        def usable_date?(str, min, max)
          date = str.to_i
          return true if date == 9999
          return false unless date >= min
          return false unless date <= max
          true
        end

        # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        # The rest of the methods handle the different date selection methods
        #  for 008 dates, depending on the 008 date type code
        # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        
        # Selects the fixed field date value to use when one is preferred
        #  but the other is allowable. In the cases where this is needed,
        #  sometimes 9999 counts as a valid date and sometimes not.
        # valid_9999 = true means 9999 IS an acceptable/desired date here
        # valid_9999 = false means 9999 is NOT and acceptable date here
        def choose_ff_date(preferred_date, fallback_date, valid_9999)
          chosen_year = preferred_date
          chosen_year = nil if chosen_year == 9999 && valid_9999 == false
          chosen_year = fallback_date if chosen_year == nil
          chosen_year = nil if chosen_year == 9999 && valid_9999 == false
          return chosen_year
        end

        # if both dates are usable, and are a sensible range, returns midpoint between them
        # if both dates are usable, but do not express a sensible range, return date1
        #  nonsensical range = date2 is earlier than or equal to date1
        # if only one of the dates is usable, return it
        def midpoint_or_usable(date1, date2)
          return date1 if date2 == 9999
          return (date1 + date2)/2 if date1 && date2 && date2 > date1
          return date1 if date1 && date2 && date2 <= date1
          return date1 if date1
          return date2 if date2
          return nil
        end

        # Handles the situation where we want date2, but have to be careful how it
        #  interacts with date1. For example:
        #  date type = d, date 1 = 1920, date 2 = 19uu means:
        #    ceased serial
        #    publication began in 1920
        #    publication ended 1900-1999
        #  Publication did not end before it began, so we need to adjust the range represented
        #    by date2 to begin at 1920
        #  Then we return the midpoint
        def date2_accounting_for_date1_in_range(date1, date2, min, max)
          date2 = date2.strip
                    
          usedate = date2.to_i unless is_range?(date2, 'fixed_field')
          usedate = Time.new.year if usedate == 9999

          if is_range?(date2, 'fixed_field') && date1
            date2start = date2.gsub('u', '0').to_i
            date2end = date2.gsub('u', '9').to_i
            date2start = date1 if date2start < date1
            usedate = (date2start + date2end)/2
          end
          usedate = nil unless usable_date?(usedate, min, max)
          usedate
        end

      end
    end
  end
end


