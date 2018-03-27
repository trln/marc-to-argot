require 'spec_helper'

describe MarcToArgot do
  include Util::TrajectRunTest
  let(:note_access_restrictions) { run_traject_json('duke', 'note_access_restrictions', 'mrc') }
  let(:note_admin_history) { run_traject_json('duke', 'note_admin_history', 'mrc') }
  let(:note_binding) { run_traject_json('duke', 'note_binding', 'mrc') }
  let(:note_copy_version) { run_traject_json('duke', 'note_copy_version', 'mrc') }
  let(:note_data_quality) { run_traject_json('duke', 'note_data_quality', 'mrc') }
  let(:note_dissertation) { run_traject_json('duke', 'note_dissertation', 'mrc') }
  let(:note_file_type) { run_traject_json('duke', 'note_file_type', 'mrc') }
  let(:note_issuance) { run_traject_json('duke', 'note_issuance', 'mrc') }
  let(:note_numbering) { run_traject_json('duke', 'note_numbering', 'mrc') }
  let(:note_organization) { run_traject_json('duke', 'note_organization', 'mrc') }
  let(:note_performer_credits_01) { run_traject_json('duke', 'note_performer_credits_01', 'mrc') }
  let(:note_performer_credits_02) { run_traject_json('duke', 'note_performer_credits_02', 'mrc') }
  let(:note_production_credits) { run_traject_json('duke', 'note_production_credits', 'mrc') }
  let(:note_report) { run_traject_json('duke', 'note_report', 'mrc') }
  let(:note_scale_01) { run_traject_json('duke', 'note_scale_01', 'mrc') }
  let(:note_scale_02) { run_traject_json('duke', 'note_scale_02', 'mrc') }
  let(:note_supplement) { run_traject_json('duke', 'note_supplement', 'mrc') }
  let(:note_system_details) { run_traject_json('duke', 'note_system_details', 'mrc') }
  let(:note_with) { run_traject_json('duke', 'note_with', 'mrc') }

  it '(Duke) sets note_access_restrictions' do
    result = note_access_restrictions['note_access_restrictions']
    expect(result).to eq(
      ['A label: Access restricted to subscribing institutions.']
    )
  end

  it '(Duke) sets note_admin_history' do
    result = note_admin_history['note_admin_history']
    expect(result).to eq(
      ['A note about admin history.']
    )
  end

  it '(Duke) sets note_binding' do
    result = note_binding['note_binding']
    expect(result).to eq(
      [{'value'=>'Perfect bound softcover. Four-color offset lithography. '\
        'Illustrated paper wrappers with flaps. Housed in foldout die-cut box '\
        'with gold foil origami crane inserted into cover slot. Signed and numbered '\
        "by the artist on book's front cover flap -- "\
        'Description from http://vampandtramp.com/finepress/s/clarissa-sligh.html'},
       {'label'=>'A label', 'value'=>'A note about the binding.'}]
    )
  end

  it '(Duke) sets note_biographical' do
    result = note_admin_history['note_biographical']
    expect(result).to eq(
      ['A unspecified Biographical or Historical Data note.', 'A biographical note.']
    )
  end

  it '(Duke) sets note_copy_version' do
    result = note_copy_version['note_copy_version']
    expect(result).to eq(
      ['A note about copy version.', 'A label: Another note about copy version.']
    )
  end

  it '(Duke) sets note_data_quality' do
    result = note_data_quality['note_data_quality']
    expect(result).to eq(
      ['Attribute accuracy: Estimated to be 98.5%. -- Village names compared to source map -- all match, '\
        'therefore errors are possible only if source maps are incorrect.',
       'Logical consistency: Node-to-line, line-to-area topological relationships maintained. '\
       'Line and area attributes maintained. GRASS 4.0 program "v.support" checks topological relationships.',
       'Horizontal position accuracy: The accuracy of this data is based upon the use of the source maps '\
       '... [subfield  --  shortened in this example]',
       'Cloud cover: 8.42%',
       'Other data details: All incorporated limits shown on USGS quads were digitized.']
    )
  end

  it '(Duke) sets note_dissertation' do
    result = note_dissertation['note_dissertation']
    expect(result).to eq(
      ['Thesis (doctoral) - Universität, Neuchâtel, 1998.',
       'Thesis/disseration--Bremen International Graduate School of Social Sciences, 2008']
    )
  end

    it '(Duke) sets note_file_type' do
    result = note_file_type['note_file_type']
    expect(result).to eq(
      ['PDF, Excel, and ASCII files.']
    )
  end

  it '(Duke) sets note_issuance' do
    result = note_issuance['note_issuance']
    expect(result).to eq(
      ['Conference for 1964 sponsored by the Board of Managers of the Nemours Foundation.',
       'Conferences for <1965- > organized by the Delaware Commission for the Aging.']
    )
  end

  it '(Duke) sets note_numbering' do
    result = note_numbering['note_numbering']
    expect(result).to include(
      'Publication suspended after v. 10, no. 3, 1943; '\
      'resumed Mar. 1948- Cf. Union List of Serials.'
    )
  end

  it '(Duke) sets note_organization' do
    result = note_organization['note_organization']
    expect(result).to include('Organized into two series: Original accession; and Addition A.')
  end

  it '(Duke) sets note_performer_credits when there is a label' do
    result = note_performer_credits_01['note_performer_credits']
    expect(result).to include({ 'label' => 'Cast', 'value' => 'Ronald Colman, Elizabeth Allan, Edna May Oliver.' })
  end

  it '(Duke) sets note_performer_credits when there is NOT a label' do
    result = note_performer_credits_02['note_performer_credits']
    expect(result).to include({ 'value' => 'Netherlands Radio Symphony Orchestra ; Jac van Steen, conductor.' })
  end

  it '(Duke) sets note_production_credits' do
    result = note_production_credits['note_production_credits']
    expect(result).to include('Producers, Leslie Midgley, John Sharnik ; director, Russ Bensley.')
  end

  it '(Duke) sets note_report_coverage' do
    result = note_report['note_report_coverage']
    expect(result).to eq(["Sept. 2000-Sept. 2005.", "Sept. 1994-Sept. 1999."])
  end

  it '(Duke) sets note_report_type' do
    result = note_report['note_report_type']
    expect(result).to eq(['Final report.'])
  end

  it '(Duke) sets note_scale from 507' do
    result = note_scale_01['note_scale']
    expect(result).to include('Scale 1:3,990,000.')
  end

  it '(Duke) sets note_scale from 255' do
    result = note_scale_02['note_scale']
    expect(result).to include('Scale 1:33,000,000 ; Mercator projection (E 15°--E 60°/N 45°--N 15°).')
  end

  it '(Duke) sets note_supplement' do
    result = note_supplement['note_supplement']
    expect(result).to eq(['Vols. for 196 - accompanied by separately paged supplement: Beteiligungen des '\
      'Bundes im Haushaltsjahr ... , issued earlier as a section of the Finanzbericht.'])
  end

  it '(Duke) sets note_system_details' do
    result = note_system_details['note_system_details']
    expect(result).to eq(
      ['v.1-2: Digital master conforms to: Benchmark for Faithful Digital Reproductions of Monographs '\
        'and Serials. Version 1. Digital Library Federation, December 2002 '\
        'http://www.diglib.org/standards/bmarkfin.htm'])
  end

  it '(Duke) sets note_with' do
    result = note_with['note_with']
    expect(result).to eq(
      ['With: Chong kan Song ben Mengzi zhu shu, [Taibei Shi : Yi wen yin shu guan, Min guo 44 i.e. 1955]',
       'With: 重栞宋本孟子注疏, [北市 : 藝文印書館, 民國44 i.e. 1955]']
    )
  end

end