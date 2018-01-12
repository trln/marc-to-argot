module MarcToArgot
  module Macros
    module NCSU
      # NCSU-specific utilities for generating
      # summary holdings from call numbers
      module Summaries
        YEAR_AT_END = %r/[^-\/\d]\(?\d*\d{4}\)?$/
        YEAR_RANGE = %r/(\d{4})\s*[\/-]\s*(\d{4})/

        def summary(call_numbers)
          return { call_no: '', summary: '' } if call_numbers.empty?
          years = call_numbers
                  .reject(&:nil?)
                  .map { |n| years(n.gsub(/\D*$/, '')) }
                  .flatten
                  .select { |x| x > 1000 && x < 2100 }
          min, max = years.minmax
          summary = if min.nil?
                      'Unknown coverage'
                    elsif min == max
                      "Issues from #{min} only"
                    else
                      "Issues from #{min} - #{max}"
                    end
          { call_no: prefix(call_numbers), summary: summary }
        end

        def years(num)
          return [] if num.nil? || num.length.zero?
          m = YEAR_AT_END.match(num)
          return m[0].to_i if m
          m = YEAR_RANGE.match(num)
          if m
            min, max = m[1..-1].map(&:to_i)
            Array(min.upto(max))
          else
            []
          end
        end

        def prefix(call_numbers = [])
          return '' if call_numbers.nil?
          cns = call_numbers.reject(&:nil?)
          return '' if cns.empty?
          return cleanup(cns.first) if cns.length == 1
          min, max = cns.minmax_by(&:length)
          # if they're all the same length, let's say 'max' is the last one
          # alphabetically
          max = cns.max if min == max
          min.chars.each_with_index do |c, i|
            return cleanup(min[0...i]) if c != max[i]
          end
        end

        def cleanup(cn)
          cn.gsub(/\D*$/, '') # remove anything that's not a digit at the end
            .gsub(/[12]\d{3}$/, '') # remove years at and
            .gsub(/(?:v|no?|#)\s*\.[\s\d]*$/i, '') # remove vol nos at end
            .gsub(/\D*$/, '')
        rescue StandardError
          cn
        end
      end
    end
  end
end
