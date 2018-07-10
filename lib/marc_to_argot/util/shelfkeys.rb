module MarcToArgot
  # Utilities namespace
  module Util
    # Utilities for handling call numbers
    module ShelfKeys
      # Map of alphanumeric characters
      # for 'inverse' shelf keys
      INVERSE = {
        '0' =>  'Z',
        '1' =>  'Y',
        '2' =>  'X',
        '3' =>  'W',
        '4' =>  'V',
        '5' =>  'U',
        '6' =>  'T',
        '7' =>  'S',
        '8' =>  'R',
        '9' =>  'Q',
        'A' =>  'P',
        'B' =>  'O',
        'C' =>  'N',
        'D' =>  'M',
        'E' =>  'L',
        'F' =>  'K',
        'G' =>  'J',
        'H' =>  'I',
        'I' =>  'H',
        'J' =>  'G',
        'K' =>  'F',
        'L' =>  'E',
        'M' =>  'D',
        'N' =>  'C',
        'O' =>  'B',
        'P' =>  'A',
        'Q' =>  '9',
        'R' =>  '8',
        'S' =>  '7',
        'T' =>  '6',
        'U' =>  '5',
        'V' =>  '4',
        'W' =>  '3',
        'X' =>  '2',
        'Y' =>  '1',
        'Z' =>  '0'
      }.freeze

      # non-alphaumerics
      NA_INVERSE = {
        '.' => '}',
        '{' => ' ',
        '|' => ' ',
        '}' => ' ',
        '~' => ' '
      }.freeze

      # Generates a 'reverse' shelf key
      # this is needed to get Solr to play nice
      # when generating browse results
      def self.reverse_shelfkey(key)
        return '' if key.nil?
        key.chars.map(&:upcase).map do |c|
          case c
          when /[[:alnum:]]/
            INVERSE[c]
          else
            NA_INVERSE.fetch(c, '~')
          end
        end.join
      end
    end
  end
end
