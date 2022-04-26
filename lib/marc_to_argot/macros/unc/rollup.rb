module MarcToArgot
  module Macros
    module UNC
      module Rollup

        def rollup_related_ids(rec, cxt)
          id_data = get_id_data(rec)

          oclc_number = set_oclc_number(id_data)
          cxt.output_hash['oclc_number'] = oclc_number if oclc_number

          ss_number = set_sersol_number(id_data) if oclc_number.nil?
          cxt.output_hash['sersol_number'] = ss_number if ss_number
          
          vendor_number = set_vendor_id(id_data)
          cxt.output_hash['vendor_marc_id'] = vendor_number if vendor_number
          
          rollup = set_rollup(oclc_number, ss_number, vendor_number)
          cxt.output_hash['rollup_id'] = rollup if rollup

          primary_oclc = set_primary_oclc(oclc_number, id_data)
          cxt.output_hash['primary_oclc'] = primary_oclc if primary_oclc
        end

        # given record, returns hash that is used by all the other methods
        # this is where we filter out data that won't be used at all, such as:
        #  - 019 subfields other than a
        #  - 035$z
        def get_id_data(rec)
          id_data = { '001' => '',
                      '003' => '',
                      '019' => [],
                      '035' => [],
                      '035z' => [],
                      '035q' => []}
          
          Traject::MarcExtractor.cached('001:003:019:035a', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
            case field.tag
            when '001'
              id_data['001'] = field.value
            when '003'
              id_data['003'] = field.value
            when '019'
              field.subfields.select{ |sf| sf.code == 'a' }.each do |sf|
                id_data['019'] << sf.value
              end
            when '035'
              field.subfields.select{ |sf| sf.code == 'a' }.each do |sf|
                id_data['035'] << sf.value
              end
              field.subfields.select{ |sf| sf.code == 'z' }.each do |sf|
                id_data['035z'] << sf.value
              end
              field.subfields.select{ |sf| sf.code == 'q' }.each do |sf|
                id_data['035q'] << sf.value
              end
            end
          end
          
          return id_data
        end

        # If either current or old OCLC number data is present, returns value of Argot oclc_number field
        # (i.e. hash with keys: value (string) and old (array)
        # otherwise, returns nil
        def set_oclc_number(id_data)
          field_value = { 'value' => '', 'old' => [] }
          oclc_num = get_oclc_number(id_data)
          old_nums = get_oclc_number_old(id_data)
          field_value['value'] = oclc_num if oclc_num
          field_value['old'] = old_nums if old_nums
          return field_value unless oclc_num.nil? && old_nums.nil?
        end

        # If a SerialsSolutions record id number is present, returns value of Argot sersol_number field
        # (i.e. a string beginning with ssj or ssib)
        # Otherwise, return nil
        # UNC locally changes SerialsSolutions monograph record ids to sseb or sse, so we change
        #   them back to standard SerialsSolutions id format here.
        def set_sersol_number(id_data)
          the001 = id_data['001']
          if the001.start_with?('ss')
            the001.sub!('sseb', 'ssib')
            the001.sub!('sse', 'ssj')
            return the001
          end
        end

        # If there are non-OCLC, non-SerialsSolutions record ids present, returns value of Argot
        #  vendor_marc_id field (i.e. an array of id strings)
        # Otherwise, return nil
        # NOTE: the alphabetic portions of these ids are inconsistently capitalized, depending on
        #  where they occur in the record. To avoid recording duplicate ids, we standardize by
        #  upcasing all of them.
        def set_vendor_id(id_data)
          ids = []
          ids << id_data['001'] unless id_data['001'].empty? || oclc_001?(id_data['001'], id_data['003'])
          the019s = id_data['019'].map{ |e| clean_001_or_019(e) }
          ids << the019s.select{ |e| oclc_001_pattern?(e) == false }
          the035s = id_data['035'].select{ |e| e.downcase.include?('(ocolc)') == false }
          the035s = the035s.map{ |e| clean_035(e) }
          ids << the035s
          ids = ids.flatten
          ids = ids.map{ |e| clean_vendor_id(e) }
          ids = ids.uniq
          return ids unless ids.empty?
          return nil
        end

        # Returns value of Argot rollup_id field (i.e. string) from other ids fields in the following
        #  order of preference (best first):
        #  - oclc_number[value]
        #  - oclc_number[old] (take first value)
        #  - sersol_number
        #  - vendor_marc_id (take first value)
        def set_rollup(oclc_number, ss_number, vendor_number)
          return 'OCLC' + oclc_number['value'] unless oclc_number.nil? || oclc_number['value'].empty?
          return 'OCLC' + oclc_number['old'].first unless oclc_number.nil? || oclc_number['old'].empty?
          return ss_number if ss_number
          return vendor_number.first if vendor_number
          return nil
        end

        def set_primary_oclc(oclc_number, id_data)
          if id_data['035q'] && !id_data['035q'].include?("exclude")         
            return oclc_number['value'] unless oclc_number.nil? || oclc_number['value'].empty?
            return nil
          end  
        end

        # Returns value of Argot oclc_number[value] if possible.
        # Otherwise return nil
        # Takes number from 001 if that ID looks like and OCLC number
        # If 001 isn't an OCLC number, look for one in 035
        # If 001 is a SerialsSolutions#, look for OCLC# in 035$z(digits only)
        def get_oclc_number(id_data)
          the001 = id_data['001']
          the003 = id_data['003']
          oclc035s = get_oclc_035s(id_data['035'])
          z035_digits_only = id_data['035z'].select { |z| z.match(/^\d+$/) }.first
          return clean_oclc_number(clean_001_or_019(the001)) if oclc_001?(the001, the003)
          return clean_oclc_number(clean_001_or_019(clean_035(oclc035s.first))) if oclc035s
          return z035_digits_only if the001.start_with?('ss') && z035_digits_only
        end

        # Returns value of Argot oclc_number[old] if possible.
        # Otherwise return nil
        # Ignore 019 values that are not OCLC numbers.
        def get_oclc_number_old(id_data)
          values = id_data['019'].map{ |e| clean_001_or_019(e) }
          values = values.select{ |e| oclc_001_pattern?(e) == true }
          values.map{ |e| clean_oclc_number(e) }
          return values unless values.empty?
        end

        # Returns true if:
        #  - the data in the 001 follows an OCLC number pattern; AND
        #  - the combination of 001 data pattern and 003 value indicates it is an OCLC number
        # 001s starting with 'tmp' are NOT OCLC numbers unless the 003 specifies OCLC
        def oclc_001?(the001, the003)
          return false if the001.start_with?('tmp') unless the003 == 'OCoLC'
          return true if oclc_001_pattern?(the001) && oclc_003?(the003)
          return false
        end

        # Returns true if cleaned 001 value matches a known OCLC number pattern
        def oclc_001_pattern?(value)
          value = clean_001_or_019(value)
          return true if /^\d+$/.match(value) #digits only
          return true if /^(hsl|tmp)\d+$/.match(value) #begin with hsl or temp, followed by digits
          return false
        end

        # Returns true if 003 value matches a known 003 appearing when 001 is an OCLC number
        def oclc_003?(value)
          oclc_003_vals = ['', 'OCoLC', 'NhCcYBP'].map{ |e| e.downcase }
          return true if oclc_003_vals.include?(value.downcase.strip)
          return false
        end

        # Returns array of the OCLC number values from 035 (excludes non-OCLC numbers)
        # Values matching "(OCoLC)M-ESTCN" are excluded because these are the OCLC numbers for print
        #  or microfilm, appearing in records for ebooks.
        # Returns nil if there are no OCLC numbers in 035
        def get_oclc_035s(the035s)
          oclc035s = the035s.select{ |v| /^ *\(ocolc\)(?!m-estcn)/.match(v.downcase) }
          return oclc035s unless oclc035s.empty?
        end

        # Initial cleanup of values from 001 or 019
        #  - removes OCLC prefixes: ocm, ocn, on
        #  - removes alphanumeric suffixes (following digits-only)
        def clean_001_or_019(value)
          value = value.downcase.strip
          value = value.sub(/^o(n|c[mn])/, '')
          value = value.sub(/^(\d+)\D\w+$/, '\1')
        end

        # Clean 035 values:
        #  - removes parenthetical data source from beginning of value
        #  - removes OCLC prefixes: ocm, ocn, on
        def clean_035(value)
          value = value.downcase.strip
          value = value.sub(/^ *\(.*\) */, '')
          value = value.sub(/^o(n|c[mn])/, '')
        end

        # Further clean an id once it has been identified as an OCLC number
        #  - remove special prefixes: hsl, tmp
        #  - remove leading zeroes
        def clean_oclc_number(value)
          value = value.downcase.strip
          value = value.sub(/^(hsl|tmp)/, '')
          value = value.sub(/^0+/, '')
        end

        # Clean and standardize vendor id values:
        #  - capitalize all alphabetic characters
        #  - remove suffixes added by UNC for local record maintenance: DDA, SUB
        def clean_vendor_id(value)
          value = value.upcase
          value = value.sub(/(DDA|SUB) *$/, '')
        end
      end
    end
  end
end
