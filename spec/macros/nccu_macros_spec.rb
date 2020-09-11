describe MarcToArgot::Macros::NCCU do
  include Util

  it 'sets primary_oclc when $q does not contain the string ‘exclude’' do
    result = run_traject_json('nccu', 'primary_oclc', 'xml')
    expect(result['primary_oclc']).to(eq(['(OCoLC)2455979(OCoLC)3112578(OCoLC)5608751']))
  end

  it 'sets primary_oclc to nil when $q contains the string ‘exclude’' do
    result = run_traject_json('nccu', 'primary_oclc_exclude', 'xml')
    expect(result['primary_oclc']).to be_nil
  end
end