describe MarcToArgot::Macros::NCCU do
  include Util

  it 'sets oclc_number' do
    result = run_traject_json('nccu', 'primary_oclc', 'xml')
    expect(result['oclc_number']).to(eq({"old"=>["3112578", "5608751"], "value"=>"2455979"}))
  end

  it 'sets oclc_number to nil when $q contains the string ‘exclude’' do
    result = run_traject_json('nccu', 'primary_oclc_exclude', 'xml')
    expect(result['oclc_number']).to(eq({"old"=>["3112578", "5608751"], "value"=>"2455979"}))
  end

  it 'sets oclc_number when $a contains (Sirsi) and $q does not contain the string ‘exclude’' do
    result = run_traject_json('nccu', 'primary_oclc_sirsi', 'xml')
    expect(result['oclc_number']).to be_nil
  end

  it 'sets oclc_number to nil when $a contains (Sirsi) and $q contains the string ‘exclude’' do
    result = run_traject_json('nccu', 'primary_oclc_sirsi_exclude', 'xml')
    expect(result['oclc_number']).to be_nil
  end

  it 'sets oclc_number to nil when there is no 035$a' do
    result = run_traject_json('nccu', 'primary_oclc_no_035a', 'xml')
    expect(result['oclc_number']).to be_nil
  end

  it 'sets primary_oclc when $q does not contain the string ‘exclude’' do
    result = run_traject_json('nccu', 'primary_oclc', 'xml')
    expect(result['primary_oclc']).to(eq(['2455979']))
  end

  it 'sets primary_oclc to nil when $q contains the string ‘exclude’' do
    result = run_traject_json('nccu', 'primary_oclc_exclude', 'xml')
    expect(result['primary_oclc']).to be_nil
  end

  it 'sets primary_oclc when $a contains (Sirsi) and $q does not contain the string ‘exclude’' do
    result = run_traject_json('nccu', 'primary_oclc_sirsi', 'xml')
    expect(result['primary_oclc']).to be_nil
  end

  it 'sets primary_oclc to nil when $a contains (Sirsi) and $q contains the string ‘exclude’' do
    result = run_traject_json('nccu', 'primary_oclc_sirsi_exclude', 'xml')
    expect(result['primary_oclc']).to be_nil
  end

  it 'sets primary_oclc to nil when there is no 035$a but $z' do
    result = run_traject_json('nccu', 'primary_oclc_no_035a', 'xml')
    expect(result['primary_oclc']).to be_nil
  end

  it 'sets rollup_id when $q does not contain the string ‘exclude’' do
    result = run_traject_json('nccu', 'primary_oclc', 'xml')
    expect(result['rollup_id']).to(eq('OCLC2455979'))
  end

  it 'sets rollup_id when $q contains the string ‘exclude’' do
    result = run_traject_json('nccu', 'primary_oclc_exclude', 'xml')
    expect(result['rollup_id']).to(eq('OCLC2455979'))
  end

    it 'sets rollup_id when $a contains (Sirsi) and $q does not contain the string ‘exclude’' do
    result = run_traject_json('nccu', 'primary_oclc_sirsi', 'xml')
    expect(result['rollup_id']).to(eq('OCLC297041'))
  end

  it 'sets rollup_id when there is no 035$a' do
    result = run_traject_json('nccu', 'primary_oclc_no_035a', 'xml')
    expect(result['rollup_id']).to(eq('OCLC3112578'))
  end
end
