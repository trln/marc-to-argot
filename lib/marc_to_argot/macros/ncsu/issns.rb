module MarcToArgot
  module Macros
    module NCSU
      # macros for extracting 'pure' issns from NCSU records
      module ISSNS
        def ncsu_issn(config)
          lambda do |rec, acc|
            st = {}
            config.each do |key, spec|
              extractor = MarcExtractor.cached(spec, separator: nil)
              issn = extractor.extract(rec).compact
              st[key] = issn.map { |s| s.strip[0..8] }.uniq unless issn.empty?
            end
            acc << st unless st.empty?
          end
        end
      end
    end
  end
end
