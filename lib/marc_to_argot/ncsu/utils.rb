module MarcToArgot
  module CallNumbers
    #def self.included(base)
    #  base.extend(NCSU)
    #end

    # NCSU-specific utilities for generating
    # summary holdings from call numbers
    module NCSU
      YEAR_AT_END = %r/[^-\/\d]\(?\d*\d{4}\)?$/
      YEAR_RANGE = %r/(\d{4})\s*[\/-]\s*(\d{4})/

      def self.summary(call_numbers)
        return { call_number: '', summary: '' } if call_numbers.empty?
        years = call_numbers
                .map { |n| years(n.gsub(/\D*$/, '')) }
                .flatten
                .select { |x| x > 1000 && x < 2100 }
        min, max = years.minmax
        summary = min == max ? "Issues from #{min} only" : "Issues from #{min} - #{max}"
        { call_number: prefix(call_numbers), summary: summary }
      end

      def self.years(num)
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

      def self.prefix(call_numbers = [])
        return '' if call_numbers.nil? || call_numbers.empty?
        return cleanup(call_numbers[0]) if call_numbers.length == 1
        min, max = call_numbers.minmax_by(&:length)
        # if they're all the same length, let's say 'max' is the last one
        # alphabetically
        max = call_numbers.max if min == max
        min.chars.each_with_index do |c, i|
          return cleanup(min[0...i]) if c != max[i]
        end
      end

      def self.cleanup(cn)
        cn.gsub(/\D*$/, '') # remove anything that's not a digit at the end
          .gsub(/[12]\d{3}$/, '') # remove years at and
          .gsub(/(?:v|no?|#)\s*\.[\s\d]*$/i, '') # remove vol nos at end
          .strip rescue cn
      end
    end
  end
end
