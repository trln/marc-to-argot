extend MarcToArgot::Macros::UNC

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
# oclc_number, sersol_number, rollup_id
# 001, 003, 035
######\

def clean_ocn_suffixes(value)
  value.gsub(/^(\d+)\D\w+$/, '\1')
end

def get_rollup_related_ids(my001, my003, my019s, my035s)
  oclcnum_003s = ['', 'OCoLC', 'NhCcYBP']
  oclcnum = ''
  ssnum = ''
  rollup = ''
  oclc_old = []
  vendor_id = []

  if my001 =~ /^\d+$/ && oclcnum_003s.include?(my003)
    oclcnum = my001
  elsif my001 =~ /^(hsl|tmp)\d+$/ && oclcnum_003s.include?(my003)
    oclcnum = my001.gsub('tmp', '').gsub('hsl', '')
  elsif my001 =~ /^\d+\D\w+$/i
    oclcnum = clean_ocn_suffixes(my001)
  elsif my001 =~ /^ss([ej]|[ie]b)\d+$/
    ssnum = my001.gsub('sseb', 'ssib').gsub('sse', 'ssj')
  end

  vendor_id << my001 if my001.length > 0 && oclcnum == '' && ssnum == ''

  if oclcnum == '' && ssnum == '' && my035s.size > 0
    oclc035s = my035s.flatten.select { |f| f.value =~ /^\(OCoLC\)\d+$/ }
    oclcnum = oclc035s[0].value.gsub(/\(OCoLC\)0*/,'') if oclc035s.size > 0
  end

  if my019s.size > 0
    my019s.flatten.each do |sf|
      oclc_old << clean_ocn_suffixes(sf.value) if sf.value =~ /^\d+/
    end
  end
  
  if oclcnum.length > 0
    rollup = "OCLC#{oclcnum}"
  elsif oclcnum == '' && oclc_old.size > 0
    rollup = "OCLC#{oclc_old[0]}"
  elsif ssnum.length > 0
    rollup = ssnum
  end

  final_onum = oclcnum if oclcnum.length > 0
  final_snum = ssnum if ssnum.length > 0
  final_rollup = rollup if rollup.length > 0
  final_oclc_old = oclc_old if oclc_old.size > 0
  final_vendor_id = vendor_id if vendor_id.size > 0

  {:oclc => final_onum, :ss => final_snum,
   :rollup => final_rollup, :oclc_old => final_oclc_old,
   :vendor_id => final_vendor_id}
end

each_record do |rec, cxt|
    my001 = ''
    my003 = ''
    my019s = []
    my035s = []
    
  Traject::MarcExtractor.cached('001:003:019:035a', alternate_script: false).each_matching_line(rec) do |field, spec, extractor|
    case field.tag
    when '001'
      my001 = field.value
    when '003'
      my003 = field.value
    when '019'
      my019s << field.subfields
    when '035'
      my035s << field.subfields
    end
  end

  results = get_rollup_related_ids(my001, my003, my019s, my035s)
  oclc_hash = {}
  oclc_hash['value'] = results[:oclc] if results[:oclc]
  oclc_hash['old'] = results[:oclc_old] if results[:oclc_old]
  cxt.output_hash['oclc_number'] = oclc_hash if oclc_hash.size > 0
  #cxt.output_hash['oclc_number'] = results[:oclc] if results[:oclc]
  cxt.output_hash['sersol_number'] = results[:ss] if results[:ss]
  cxt.output_hash['rollup_id'] = results[:rollup] if results[:rollup]
  #cxt.output_hash['oclc_number_old'] = results[:oclc_old] if results[:oclc_old]
  cxt.output_hash['vendor_marc_id'] = results[:vendor_id] if results[:vendor_id]
end

################################################
# Items
# https://github.com/trln/extract_marcxml_for_argot_unc/blob/master/attached_record_data_mapping.csv
######
def status_map
  @status_map ||=Traject::TranslationMap.new('unc/status_map')
end

def loc_hierarchy_map
  @loc_hierarchy_map ||=Traject::TranslationMap.new('unc/loc_b_to_hierarchy')
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
      subfield.value.strip! #delete leading/trailing spaces
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

    ilocs = items.collect { |it| it['loc_b'] }
    hier_loc_code_strings = ilocs.collect { |loc| loc_hierarchy_map[loc] }.flatten
    clean_loc_strings = hier_loc_code_strings.select { |e| e.nil? == false }
#    ctx.output_hash['hiertest'] = clean_loc_strings
    if clean_loc_strings.size > 0
      ctx.output_hash['location_hierarchy'] = explode_hierarchical_strings(clean_loc_strings)
    end
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
