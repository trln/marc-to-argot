# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::Shared::Notes do
  include Util::TrajectRunTest
  let(:note_access_restrictions) { run_traject_json('duke', 'note_access_restrictions', 'mrc') }
  let(:note_admin_history) { run_traject_json('duke', 'note_admin_history', 'mrc') }
  let(:note_binding) { run_traject_json('duke', 'note_binding', 'mrc') }
  let(:note_cited_in1) { run_traject_json('unc', 'note_cited_in1', 'mrc') }
  let(:note_cited_in2) { run_traject_json('unc', 'note_cited_in2', 'mrc') }
  let(:note_copy_version) { run_traject_json('duke', 'note_copy_version', 'mrc') }
  let(:note_data_quality) { run_traject_json('duke', 'note_data_quality', 'mrc') }
  let(:note_dissertation) { run_traject_json('duke', 'note_dissertation', 'mrc') }
  let(:note_file_type) { run_traject_json('duke', 'note_file_type', 'mrc') }
  let(:note_former_title) { run_traject_json('duke', 'note_former_title', 'mrc') }
  let(:note_general) { run_traject_json('duke', 'note_general', 'mrc') }
  let(:note_issuance) { run_traject_json('duke', 'note_issuance', 'mrc') }
  let(:note_local) { run_traject_json('duke', 'note_local', 'mrc') }
  let(:note_local2) { run_traject_json('unc', 'note_local2', 'xml') }
  let(:note_methodology) { run_traject_json('duke', 'note_methodology', 'mrc') }
  let(:note_numbering) { run_traject_json('duke', 'note_numbering', 'mrc') }
  let(:note_organization) { run_traject_json('duke', 'note_organization', 'mrc') }
  let(:note_performer_credits_01) { run_traject_json('duke', 'note_performer_credits_01', 'mrc') }
  let(:note_performer_credits_02) { run_traject_json('duke', 'note_performer_credits_02', 'mrc') }
  let(:note_production_credits) { run_traject_json('duke', 'note_production_credits', 'mrc') }
  let(:note_related_work_01) { run_traject_json('duke', 'note_related_work_01', 'mrc') }
  let(:note_related_work_02) { run_traject_json('duke', 'note_related_work_02', 'mrc') }
  let(:note_related_work_03) { run_traject_json('duke', 'note_related_work_03', 'mrc') }
  let(:note_report) { run_traject_json('duke', 'note_report', 'mrc') }
  let(:note_reproduction_01) { run_traject_json('duke', 'note_reproduction_01', 'mrc') }
  let(:note_reproduction_02) { run_traject_json('duke', 'note_reproduction_02', 'mrc') }
  let(:note_scale_01) { run_traject_json('duke', 'note_scale_01', 'mrc') }
  let(:note_scale_02) { run_traject_json('duke', 'note_scale_02', 'mrc') }
  let(:note_serial_dates) { run_traject_json('unc', 'note_serial_dates', 'mrc') }
  let(:note_supplement) { run_traject_json('duke', 'note_supplement', 'mrc') }
  let(:note_system_details) { run_traject_json('duke', 'note_system_details', 'mrc') }
  let(:note_with) { run_traject_json('duke', 'note_with', 'mrc') }
  let(:note_system_details_vernacular) { run_traject_json('unc', 'vern_note_sys_det', 'mrc') }
  
  it '(MTA) sets note_access_restrictions' do
    result = note_access_restrictions['note_access_restrictions']
    expect(result).to eq(
      ['A label: Access restricted to subscribing institutions.']
    )
  end

  it '(MTA) sets note_admin_history' do
    result = note_admin_history['note_admin_history']
    expect(result).to eq(
      ['A note about admin history.']
    )
  end

  it '(MTA) sets note_binding' do
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

  it '(MTA) does NOT set note_binding from field with non-whitelisted $5 value' do
    result = note_local2['note_binding']
    expect(result).to eq(nil)
  end

  xit '(MTA) sets cited_in note, including ISSN label' do
    result = note_cited_in1['note_cited_in']
    expect(result).to eq(
                        [
                          'Chemical abstracts ISSN 0009-2258 1968-1986'
                        ]
                      )
  end

  xit '(MTA) sets cited_in note with $3 label' do
    result = note_cited_in2['note_cited_in']
    expect(result).to eq(
                        [
                          'Arcadelt, Quinto libro: RISM B/I, B1544-16',
                          'Arcadelt, Quinto libro: RISM A/I, A1382',
                          'Arcadelt, Secondo libro: RISM A/I, A1371',
                          'Arcadelt, Terzo libro: RISM B/I, 1539-23',
                          'Arcadelt, Terzo libro: RISM A/I, A1374'
                        ]
                      )
  end
  
  it '(MTA) sets note_biographical' do
    result = note_admin_history['note_biographical']
    expect(result).to eq(
      ['A unspecified Biographical or Historical Data note.', 'A biographical note.']
    )
  end

  it '(MTA) sets note_copy_version' do
    result = note_copy_version['note_copy_version']
    expect(result).to eq(
      ['A note about copy version.', 'A label: Another note about copy version.']
    )
  end

  it '(MTA) sets note_data_quality' do
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

  it '(MTA) sets note_dissertation' do
    result = note_dissertation['note_dissertation']
    expect(result).to eq(
      ['Thesis (doctoral) - Universität, Neuchâtel, 1998.',
       'Thesis/disseration--Bremen International Graduate School of Social Sciences, 2008',
       'Thesis--Ph.D--University of North Carolina at Chapel Hill.',
       'Recital document--Master of Music in Performance and Vocal Pedagogy--University of Texas at San Antonio, 2012.',
       'Ph. D.--University of North Carolina, 1976']
    )
  end

  it '(MTA) sets note_file_type' do
    result = note_file_type['note_file_type']
    expect(result).to eq(
      ['PDF, Excel, and ASCII files.']
    )
  end

  it '(MTA) sets note_former_title' do
    result = note_former_title['note_former_title']
    expect(result).to eq(
      ['Resource originally known as NetLibrary, owned and maintained by NetLibrary, '\
       'a division of OCLC, <Feb. 8, 2010>- ; resource purchased by EBSCOhost and relaunched '\
       'as "ebook Collection", <July 22, 2011>-']
    )
  end

  it '(MTA) sets note_general' do
    result = note_general['note_general']
    expect(result).to eq([
      {'value' => 'Translation is based on a photocopy of the original MS. in the '\
                  'Library of Pembroke College, Oxford.'},
      {'value' => 'Number of references: 36 references.',
      'indexed' => 'false'},
      {'value' => 'Bibliography : p. 81-83. Number of references: 52.',
      'indexed' => 'false'},
      {'label' => '1st-4th works',
       'value' => 'recorded 2013 January 25-27 St. Mary\'s Church, Chilham, Kent.',
       'indexed' => 'false'},
      {'label' => '5th work',
       'value' => 'recorded 2013 January 31 No. 2 Studio, Abbey Road, London.',
       'indexed' => 'false'},
      {'value' => 'Recorded June 11-18, 1981, Corbett Auditorium, College-Conservatory of Music, University of Cincinnati.',
       'indexed' => 'false'},
      {'value' => '"The professional bulletin for Army engineers."',
       'indexed' => 'false'},
      {'label' => 'For audience(s)',
       'value' => 'Scholarly & Professional (source: IEEE Computer Society Press)',
       'indexed' => 'false'},
      {'label' => 'For grade(s)',
       'value' => '4.5.',
       'indexed' => 'false'},
      {'label' => 'Workbook: For age(s)',
       'value' => '3 to 7.',
       'indexed' => 'false'},
      {'label' => 'For grade(s)',
       'value' => '7-12. (source: Brodart)',
       'indexed' => 'false'},
      {'label' => 'For audience(s)',
       'value' => 'Older adults; younger persons with disabilities.',
       'indexed' => 'false'},
      {'value' => '"The non-OECD countries in this report comprise ... central and Eastern European '\
                  'countries (CEECs), major New Indepenent States (NIS), and China, Brazil, and India ..."'},
      {'label' => 'Geographic coverage',
       'value' => 'Asia-Pacific ; Africa ; Near East ; Americas ; Europe ; Argentina ; Uruguay ; Brazil ; Chile ; Peru.'},
      {'label' => 'Reading program: 2017 addition to',
       'value' => 'Accelerated Reader -- Interest level: Grades 5-8 -- Reading level: 4.9 '\
                  '-- Title points: 10 -- Quiz 161076 -- English fiction.',
       'indexed_value' => 'Accelerated Reader'},
      {'value' => 'CE credits available from Psychotherapy.net'},
      {'label' => 'Funding details',
       'value' => 'Headquarters, U.S. Army Corps of Engineers. 4A162784, AT 45, FF-XS5.'},
      {'label' => 'Text',
       'value' => 'Latin'},
      {'label' => 'Introduction and notes',
       'value' => 'German'},
      {'label' => 'Documentation',
      'value' => 'IPEDS peer analysis system user manual, self guided tutorials.',
      'indexed' => 'false'},
      {'value' => 'Accompanied by user\'s manual (in English and French). Title on manual: '\
                  'Mayer international auction records on CD-ROM.',
      'indexed' => 'false'},
      {'label' => 'Paintings, calligraphies, seal carvings',
       'value' => 'Exhibited: University Museum and Art Gallery, The University of Hong Kong, '\
                  'sponsored by Mr. Frankie W., October 29, 2004-December 9, 2004.'},
      {'value' => '"Published in conjunction with the exhibition Wiener Werkstätte 1903-1932 : '\
                  'the luxury of beauty, Neue Galerie New York, October 26, 2017-'\
                  'January 29, 2018" (title page verso).'},
      {'value' => 'Academy Awards, 2003: Best Documentary, Features (Michael Moore, Michael Donovan)'},
      {'value' => 'Cannes Film Festival, 2002: 55th Anniversary Prize (Michael Moore)'},
      {'label' => 'Ana',
      'value' => 'Dai 150-kai Akutagawa-shō, 2014'}
    ])
  end

  it '(MTA) sets note_issuance' do
    result = note_issuance['note_issuance']
    expect(result).to eq(
      ['Conference for 1964 sponsored by the Board of Managers of the Nemours Foundation.',
       'Conferences for <1965- > organized by the Delaware Commission for the Aging.']
    )
  end

  it '(MTA) sets note_local' do
    result = note_local['note_local']
    expect(result).to eq(
      [{'label' => 'c. 1',
        'value' => 'Inscribed: "Benson R. Wilcox"--Fly leaf.'},
      {'label' => 'Source of acquisition',
         'value' => 'Presented by Benson R. Wilcox (Gift : 2010 : Health Sciences Library, c. 1)',
         'indexed_value' => 'Presented by Benson R. Wilcox'},
        {'label' => 'Ownership history: c. 1',
         'value' => 'Bookplate: "Ex Libris Benson R. Wilcox M.D."--Inside front cover.'},
        {'value' => 'RBC PQ4315.58 .R7 1896 c. 1: RBC: Bound in ivory paper yapp fore-edges deckle edges notations and markings throughout.'}
      ]
    )
  end

  it '(MTA) does NOT set note_local from field with non-whitelisted $5 value' do
    result = note_local2['note_local']
    expect(result).to eq(nil)
  end

  it '(MTA) sets note_methodology' do
    result = note_methodology['note_methodology']
    expect(result).to eq(
      ['Samples from 319 quadrangles (1 degree x 2 degrees) beginning in 1976 and ending in 1980; '\
       'four main sample types represented: stream sediment, soil, surface water, and ground water. '\
       'Each sample analyzed for uranium and as many as 58 other elements including sulfate.']
    )
  end

  it '(MTA) sets note_numbering' do
    result = note_numbering['note_numbering']
    expect(result).to include(
      'Publication suspended after v. 10, no. 3, 1943; '\
      'resumed Mar. 1948- Cf. Union List of Serials.'
    )
  end

  it '(MTA) sets note_organization' do
    result = note_organization['note_organization']
    expect(result).to include('Publications and correspondence: Organized into two series: Original accession; and Addition A.')
  end

  it '(MTA) sets note_performer_credits when there is a label' do
    result = note_performer_credits_01['note_performer_credits']
    expect(result).to include({ 'label' => 'Cast', 'value' => 'Ronald Colman, Elizabeth Allan, Edna May Oliver.' })
  end

  it '(MTA) sets note_performer_credits when there is NOT a label' do
    result = note_performer_credits_02['note_performer_credits']
    expect(result).to include({ 'value' => 'Netherlands Radio Symphony Orchestra ; Jac van Steen, conductor.' })
  end

  it '(MTA) sets note_production_credits' do
    result = note_production_credits['note_production_credits']
    expect(result).to include('Producers, Leslie Midgley, John Sharnik ; director, Russ Bensley.')
  end

  it '(MTA) sets note_related_work for 535' do
    result = note_related_work_01['note_related_work']
    expect(result).to eq([{'label' => 'Originals held by',
                           'value' => 'Diocesan Library, Episcopal Diocese of Western North '\
                                      'Carolina, P. O. Box 368, Black Mountain, N.C. 28711.',
                           'indexed' => 'false'},
                           {'label' => 'Microfilm: Duplicates held by',
                           'value' => 'Church of Jesus Christ of the Latter-day Saints. '\
                           'Family History Center, Greensboro, N.C.',
                           'indexed' => 'false'}])
  end

  it '(MTA) sets note_related_work for 544' do
    result = note_related_work_02['note_related_work']
    expect(result).to eq([{'value' => 'See also James Ritchie Sparkman books (#2732); '\
                                      'Sparkman family papers (#2791) at the Southern Historical Collection, '\
                                      'University of North Carolina at Chapel Hill.',
                           'indexed_value' => 'See also James Ritchie Sparkman books (#2732); '\
                                              'Sparkman family papers (#2791) at the'},
                          {'value' => 'See also W.E. Sparkman account book at the South Caroliniana Library, '\
                                      'University of South Carolina.',
                           'indexed_value' => 'See also W.E. Sparkman account book at the'},
                          {'value' => 'The North Carolina Collection Photographic Archives, '\
                                      'University of North Carolina at Chapel Hill, holds many collections '\
                                      'with images relating to the history of the University of '\
                                      'North Carolina at Chapel Hill.',
                           'indexed' => 'false'},
                          {'label' => 'Related materials',
                           'value' => 'William R. Ferris Collection, #20367 in the, Southern Folklife '\
                                      'Collection, University of North Carolina at Chapel Hill.',
                           'indexed_value' => 'William R. Ferris Collection, #20367 in the,'},
                          {'label' => 'Documents from 1970s: Related materials',
                           'value' => 'William R. Ferris Collection, #20367 in the, Southern Folklife '\
                                      'Collection, University of North Carolina at Chapel Hill.',
                           'indexed_value' => 'William R. Ferris Collection, #20367 in the,'}])
  end

  it '(MTA) sets note_related_work for 580' do
    result = note_related_work_03['note_related_work']
    expect(result).to eq([{'value' => 'Merged with: Botanica acta, to form: Plant biology (Stuttgart, Germany).',
                           'indexed' => 'false'}])
  end

  it '(MTA) sets note_report_coverage' do
    result = note_report['note_report_coverage']
    expect(result).to eq(["Sept. 2000-Sept. 2005.", "Sept. 1994-Sept. 1999."])
  end

  it '(MTA) sets note_report_type' do
    result = note_report['note_report_type']
    expect(result).to eq(['Final report.'])
  end

  it '(MTA) sets note_reproduction from 533' do
    result = note_reproduction_01['note_reproduction']
    expect(result).to eq([{'label' => 'A label',
                           'value' => 'Microfiche. Arlington, Va. : University Publications of America. '\
                                      '1998. 1 microfiche : negative. (Major studies and issue briefs of '\
                                      'the Congressional Research Service. 1998 supplement ; 98-IB-97042).',
                           'indexed_value' => 'University Publications of America. '\
                                              '(Major studies and issue briefs of the Congressional '\
                                              'Research Service. 1998 supplement ; 98-IB-97042).'}])
  end

  it '(MTA) sets note_reproduction from 534' do
    result = note_reproduction_02['note_reproduction']
    expect(result).to eq([{'label' => 'Original version',
                          'value' => 'New York : Published by Currier & Ives, c1892. Copyright 1892 by Currier & Ives, N.Y.',
                          'indexed' => 'false'},
                          {'label' => 'Original version in',
                           'value' => 'Bry, Theodor de, 1528-1598. Admiranda narratio, fida tamen, de commodis et incolarum '\
                                      'ritibus Virginæ ... America. pt. 1. Francoforti ad Moenum, 1590.',
                           'indexed_value' => 'Bry, Theodor de, 1528-1598. Admiranda narratio, fida tamen, de commodis et '\
                                              'incolarum ritibus Virginæ ... America.'},
                          {'label' => 'Facsimilie reprint. Originally published',
                           'value' => 'New York : D. Appleton and Company, 1894.',
                           'indexed' => 'false'},
                          {'label' => 'Works 1-12: issued earlier as analog disc',
                           'value' => 'Arhoolie 5036.',
                           'indexed' => 'false'},
                          {'label' => 'Electronic reproduction. Originally published in',
                           'value' => 'Fontes rerum bohemicarum. T. 3. Prague : Nákl. N.F. Palackého, [1882]',
                           'indexed_value' => 'Fontes rerum bohemicarum.'},
                          {'label' => 'Original version',
                           'value' => 'Faksimile-uitg. van de autografen, 1786, 1787.',
                           'indexed' => 'false'}
                          ])
  end

  it '(MTA) sets note_scale from 507' do
    result = note_scale_01['note_scale']
    expect(result).to include('Scale 1:3,990,000.')
  end

  it '(MTA) sets note_scale from 255' do
    result = note_scale_02['note_scale']
    expect(result).to include('Scale 1:33,000,000 ; Mercator projection (E 15°--E 60°/N 45°--N 15°).')
  end

  it '(MTA) sets note_serial_dates from 362' do
    result = note_serial_dates['note_serial_dates']
    expect(result).to eq(
                        ['Began with v. 1 in 1846; ceased in Mar. 1934. (Data from: Union list of serials.)',
                         'Aug. 1, 1959-Aug. 1, 1965.'
                        ]
                      )
  end

  it '(MTA) sets note_supplement' do
    result = note_supplement['note_supplement']
    expect(result).to eq(['Vols. for 196 - accompanied by separately paged supplement: Beteiligungen des '\
      'Bundes im Haushaltsjahr ... , issued earlier as a section of the Finanzbericht.'])
  end

  it '(MTA) sets note_system_details' do
    result = note_system_details['note_system_details']
    expect(result).to eq(
      ['v.1-2: Digital master conforms to: Benchmark for Faithful Digital Reproductions of Monographs '\
        'and Serials. Version 1. Digital Library Federation, December 2002 '\
        'http://www.diglib.org/standards/bmarkfin.htm',
       'Videodisc: DVD; stereo. or 5.1 surround.'
      ])
  end

  it '(MTA) sets note_with' do
    result = note_with['note_with']
    expect(result).to eq(
      ['With: Chong kan Song ben Mengzi zhu shu, [Taibei Shi : Yi wen yin shu guan, Min guo 44 i.e. 1955]',
       'With: 重栞宋本孟子注疏, [北市 : 藝文印書館, 民國44 i.e. 1955]']
    )
  end

  xit '(MTA) sets note_system_details from vernacular' do
    result = note_system_details_vernacular['note_system_details']
    expect(result).to eq(
                        [ 'Xi tong yao qiu: Blu-ray bo fang she bei ji xiang guan ruan jian.',
                          '系统要求: Blu-ray播放设备及相关软件.'
      ])
  end

end
