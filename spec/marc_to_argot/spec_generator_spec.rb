require 'spec_helper'

describe MarcToArgot::SpecGenerator do
  it 'loads default spec successfully' do
    spec = MarcToArgot::SpecGenerator.new('argot')
    result = spec.generate_spec
    expect(result).to be_kind_of(Hash)
    expect(result).not_to be_empty
    expect(result['id']).to eq('001')
  end

  it 'provides correct default spec when nonexisting collection specified' do
    spec = MarcToArgot::SpecGenerator.new('bleh')
    spec.get_override_spec_path
    dresult = spec.default_spec_file
    expect(dresult).to include('data/argot/marc_specs.yml')
    oresult = spec.override_spec_file
    expect(oresult).to eq(nil)
  end

  it 'provides correct default spec when random file specified' do
    spec = MarcToArgot::SpecGenerator.new('spec/data/test_marc_spec.yaml')
    spec.get_override_spec_path
    dresult = spec.default_spec_file
    expect(dresult).to include('data/argot/marc_specs.yml')
    oresult = spec.override_spec_file
    expect(oresult).to include('spec/data/test_marc_spec.yaml')
  end

  it 'provides correct spec paths when no collection specified' do
    spec = MarcToArgot::SpecGenerator.new('')
    spec.get_override_spec_path
    dresult = spec.default_spec_file
    expect(dresult).to include('data/argot/marc_specs.yml')
    oresult = spec.override_spec_file
    expect(oresult).to eq(nil)
  end
  
  it 'provides correct spec paths when existing collection specified' do
    spec = MarcToArgot::SpecGenerator.new('unc')
    spec.get_override_spec_path
    dresult = spec.default_spec_file
    oresult = spec.override_spec_file
    expect(dresult).to include('data/argot/marc_specs.yml')
    expect(oresult).to include('data/unc/marc_specs.yml')
  end

  it 'loads default spec successfully as default when nonexisting collection specified' do
    spec = MarcToArgot::SpecGenerator.new('greentomato')
    result = spec.generate_spec
    expect(result).to be_kind_of(Hash)
    expect(result).not_to be_empty
    expect(result['id']).to eq('001')
  end

  it 'loads default spec successfully as default when no collection specified' do
    spec = MarcToArgot::SpecGenerator.new('')
    result = spec.generate_spec
    expect(result).to be_kind_of(Hash)
    expect(result).not_to be_empty
    expect(result['id']).to eq('001')
  end

  it 'provides correct oclc_number spec from default when not specified in override spec' do
    spec = MarcToArgot::SpecGenerator.new('spec/data/test_marc_spec.yaml')
    result = spec.generate_spec
    expect(result['oclc_number']).to eq('035a')
  end

  it 'provides correct fake spec from override spec when that field is not specified in default spec' do
    spec = MarcToArgot::SpecGenerator.new('spec/data/test_marc_spec.yaml')
    result = spec.generate_spec
    expect(result['fake_field']).to eq('foo')
  end
  
  it 'handles nested field specs properly' do
    spec = MarcToArgot::SpecGenerator.new('spec/data/test_marc_spec.yaml')
    result = spec.generate_spec
    expect(result['notes']['indexed']).to eq('500a:533a')
    expect(result['notes']['additional']).to include('546ab')
  end
  
  it 'loads NCSU spec without a problem' do
    spec = MarcToArgot::SpecGenerator.new('ncsu')
    result = spec.generate_spec
    expect(result['id']).to eq('918a')
  end

  it 'loads Duke spec without a problem' do
    spec = MarcToArgot::SpecGenerator.new('duke')
    result = spec.generate_spec
    expect(result['id']).to eq('001')
  end

  it 'loads UNC spec without a problem' do
    spec = MarcToArgot::SpecGenerator.new('unc')
    result = spec.generate_spec
    expect(result['id']).to eq('907a')
  end

end
