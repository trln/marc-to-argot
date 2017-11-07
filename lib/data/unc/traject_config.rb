################################################
# Primary ID
######
to_field 'id', extract_marc(settings['specs'][:id], :first => true) do |rec, acc|
  acc.collect! {|s| "UNC#{s}"}
end

################################################
# Local ID
######
to_field 'local_id' do |rec, acc|
  primary = Traject::MarcExtractor.cached('907a').extract(rec).first
  primary = primary.delete('.') if primary

  local_id = {
              :value => primary,
              :other => []
             }

  # do things here for "Other"

  acc << local_id
end

################################################
# Institution
######\
to_field 'institution', literal('unc')

################################################
# Items
# https://github.com/trln/extract_marcxml_for_argot_unc/blob/master/attached_record_data_mapping.csv
######
def status_map
  @status_map ||=Traject::TranslationMap.new('unc/status_map')
end

def loc_hierarchy_map
  @loc_hierarchy_map ||=Traject::TranslationMap.new('unc/loc_b_to_location_hierarchy')
end

def is_available?(items)
  available_statuses = ['Ask the MRC', 'Available', 'Contact library for status', 'In-Library Use Only']
  items.any? { |i| available_statuses.include?(i['status']) rescue false }
end

def set_cn_scheme(marc_tag, i1, i2)
  case marc_tag
  when '050'
    'LC'
  when '060'
    'NLM'
  when '070'
    'NAL'
  when '082'
    'DDC'
  when '083'
    'DDC'
  when '090'
    'LC'
  when '092'
    'DDC'
  when '086'
    if i1 == '0'
      'SUDOC'
    else
      'OTHERGOVDOC'
    end
  when '099'
    'ALPHANUM'
  end
end

to_field 'items' do |rec, acc, ctx|

  formats = marc_formats.call(rec, [])
  items = []

  Traject::MarcExtractor.cached('999|*1|cdilnpqsv', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|

    item = {}
    public_notes = []

    field.subfields.each do |subfield|
      sf = subfield.code
      subfield.value.gsub!(/\|./, ' ') #remove subfield delimiters and
      subfield.value.strip! #delet leading/trailing spaces
      case sf
      when 'c'
        item['copy_no'] = subfield.value if subfield.value != '1'
      when 'd'
        item['due_date'] = subfield.value
      when 'i'
        item['id'] = subfield.value
      when 'l'
        item['loc_b'] = subfield.value
        item['loc_n'] = subfield.value
      when 'n'
        public_notes << subfield.value
      when 'p'
        item['cn_scheme'] = set_cn_scheme(subfield.value[0, 3], subfield.value[3], subfield.value[4])
      when 'q'
        item['call_no'] = subfield.value
      when 's'
        item['status'] = status_map[subfield.value]
      when 'v'
        item['vol'] = subfield.value
      end
    end

    #add notes to item
    item['notes'] = public_notes if public_notes.size > 0

    #set checked out status
    item['status'] = 'Checked out' if item['due_date']

    items << item
    acc << item.to_json if item

    #set Availability facet value affirmatively
    ctx.output_hash['available'] = 'Available' if is_available?(items)
    map_call_numbers(ctx, items)


    loc_facet_mess = []
    ilocs = items.collect { |it| it['loc_b'] }
    ilocs.uniq.each do |loc|
      rawloc = loc_hierarchy_map[loc]
      rawloc.each do |e|
        loc_facet_mess << array_to_hierarcy_facet(e.split(':'))
      end
    end
    ctx.output_hash['location_hierarchy'] = arrays_to_hierarchy(loc_facet_mess)
  end
end

################################################
# Holdings
######

to_field 'holdings' do |rec, acc|
  holdings = []
  holdings_ff = [] #fixed field level info from holdings records
  holdings_vf = {} #variable field level info from holdings records
  # holdings_vf = {'c1234567' => [
  #                               {'marctag' => '852',
  #                                'iiitag' => 'c',
  #                                'otherfields' => [['h', 'HC102'], ['i', '.D8'], ['z', 'Does not circulate']]
  #                                },
  #                               {'marctag' => '866',
  #                                'iiitag' => 'h',
  #                                'linkid' => '0',
  #                                'other_fields' => [['a', '1979:v.1, 1980 - 1987:A-F, 1987:P-2011']]
  #                                },
  #                               ]
  #                }

  Traject::MarcExtractor.cached('999|*2|abc', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
    this_holding = {}
    field.subfields.each do |subfield|
      sf = subfield.code
      val = subfield.value
      val.gsub!(/\|./, ' ') #remove subfield delimiters and
      val.strip! #delete leading/trailing spaces

      case sf
      when 'a'
        this_holding[:holdings_id] = val
        holdings_vf[val] = []
      when 'b'
        this_holding[:loc] = val
      when 'c'
        this_holding[:checkin_card_ct] = val.to_i
      end
    end
    holdings_ff << this_holding
  end

  Traject::MarcExtractor.cached('999|*3|', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|

    keep_fields = ['852', '866', '867', '868']
    this_field = {}
    other_fields = []

    field.subfields.each do |subfield|
      sf = subfield.code
      val = subfield.value
      val.gsub!(/\|./, ' ') #remove subfield delimiters and
      val.strip! #delete leading/trailing spaces
      case sf
      when '0'
        this_field[:hrec] = val
      when '2'
        this_field[:marctag] = val
      when '3'
        this_field[:iiitag] = val
      when '8'
        this_field[:linkid] = val
      else
        other_fields << [sf, val]
      end
    end

    if keep_fields.include?(this_field[:marctag])
      this_field[:other_fields] = other_fields
      holdings_vf[this_field[:hrec]] << this_field
    end
  end

  holdings_ff.each do |hrec|
    holding = {}
    holding['holdings_id'] = hrec[:holdings_id] if hrec[:checkin_card_ct] > 0
    holding['loc_b'] = hrec[:loc]
    holding['loc_n'] = hrec[:loc]

    varfields = holdings_vf[hrec[:holdings_id]]
    notes = []

    #set call number and holdings notes from 852 with iiitag c
    cn_f = varfields.select { |f| f[:marctag] == '852' && f[:iiitag] == 'c' }
    if cn_f.size > 0
      cns = []
      cn_f.each do |cnf|
        this_cn = []
        cnf[:other_fields].each do |e|
          this_cn << e[1] if e[0] =~ /[hijk]/
          notes << e[1] if e[0] == 'z'
        end
        cns << this_cn.join(' ')
      end
      holding['call_no'] = cns.join('; ')
      holding['notes'] = notes if notes.size > 0
    end

    #set summary holdings and notes from 866, 867, 868
    sum_f = varfields.select { |f| f[:marctag] =~ /86[678]/ }
    if sum_f.size > 0
      sums = []
      sum_f.each do |sumf|
        this_sum = []
        sumf[:other_fields].each do |e|
          this_sum << e[1] if e[0] == 'a'
          notes << e[1] if e[0] == 'z'
        end
        
        case sumf[:marctag]
        when '867'
          sums << "Supplementary holdings: #{this_sum.join(', ')}"
        when '868'
          sums << "Index holdings: #{this_sum.join(', ')}"
        else
          sums << this_sum.join(', ')
        end
      end

      holding['summary'] = sums.join('; ')
      holding['notes'] = notes.uniq if notes.size > 0
    end

    acc << holding.to_json if holding
  end
  
end
