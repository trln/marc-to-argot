module MarcToArgot
  module Macros
    module NCSU
      module SersolNumber

        # accumulates an array of serial solution numbers
        def sersol_number
          lambda do |rec, acc|
            Traject::MarcExtractor.cached('035a').each_matching_line(rec) do |field, spec, extractor|
              ids = field.subfields.select { |sf| sf.code == 'a' }.map(&:value).map(&:strip)
              ids.select! { |x| /^(\(WaSeSS\)ssj)?\d{5,}$/.match(x) }
              ids.map! { |x| x.sub('(WaSeSS)', '') }              
              acc << ids
              acc.compact!
              acc.flatten!
              acc.reject!(&:empty?)
              acc.uniq!
            end
          end
        end
      end
    end
  end
end