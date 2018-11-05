# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::Shared::TitleVariant do
  include Util::TrajectRunTest
  let(:title_variant) { run_traject_json('duke', 'title_variant', 'mrc') }

  it '(MTA) sets title_variant' do
    result = title_variant['title_variant']
    expect(result).to eq(
      [{'type' => 'abbrev',
        'value' => 'GATT act.',
        'display' => 'false'},
       {'type' => 'abbrev',
        'value' => 'New-England j. med. surg. collat. branches sci.',
        'display' => 'false'},
       {'type' => 'key',
        'value' => 'advocate of peace and universal brotherhood (Online)',
        'display' => 'false'},
       {'value' => 'Early Russian architecture',
        'display' => 'false'},
       {'value' => 'Architecture de la vieille Russie',
        'display' => 'false'},
       {'value' => 'Altrussische Baukunst',
        'display' => 'false'},
       {'value' => 'Arquitectura de la antigua Rus',
        'display' => 'false'},
       {'value' => 'Revista do Instituto Historico e Geographico Brazileiro',
        'display' => 'false'},
       {'label' => 'Spine title',
        'value' => 'Cicero\'s epistles'},
       {'label' => 'Title varies',
        'value' => 'Academic science and engineering. R&D expenditures 1990-',
        'indexed_value' => 'Academic science and engineering. R&D expenditures'},
       {'label' => 'Title on t.p. verso',
        'value' => 'Bright ray of hope'},
       {'value' => 'ARBA [serial].',
        'indexed_value' => 'ARBA'},
       {'label' => 'Added title page title: Book 3',
        'value' => 'Onuphrij Panuinij Veronensis Fratris Eremitae Augustiniani Imperium Romanum'},
       {'label' => 'Added title page title: Book 2',
        'value' => 'Onuphrij Panuinij Veronensis Fratris Eremitae Augustiniani Ciuitas Romana'},
       {'value' => 'Loving pretty women',
        'display' => 'false'},
       {'value' => 'GATT activities',
        'display' => 'false'},
       {'type' => 'former',
        'label' => '1840-42',
        'value' => 'Lowell offering : a repository of original articles, written exclusively by females actively employed in the mills (title varies slightly)',
        'indexed_value' => 'Lowell offering : a repository of original articles, written exclusively by females actively employed in the mills'},
       {'type' => 'former',
        'label' => 'v. 3-24, no. 3, 1987-2009',
        'value' => 'Labor lawyer',
        'issn' => '8756-2995'},
       {'type' => 'former',
        'value' => 'Anales de las Reales Junta de Fomento y Sociedad Económica de la Habana',
        'display' => 'false'}]
    )
  end

  xit '(MTA) sets non-Roman title_variant from 880' do
    rec = make_rec
    rec << MARC::DataField.new('880', '1', '4', ['6', '246-04/(N'], ['a', 'Сказки Афанасьева'])
    argot = run_traject_on_record('unc', rec)
    result = argot['title_variant']
    expect(result).to eq([{'type' => 'variant',
                           'label' => 'Cover title',
                           'value' => 'Сказки Афанасьева',
                           'lang' => 'rus'
                          }])
  end

    xit '(MTA) sets non-Roman title_variant from 880' do
    rec = make_rec
    rec << MARC::DataField.new('246', '1', '4', ['a', 'Сказки Афанасьева'])
    argot = run_traject_on_record('unc', rec)
    result = argot['title_variant']
    expect(result).to eq([{'type' => 'variant',
                           'label' => 'Cover title',
                           'value' => 'Сказки Афанасьева',
                           'lang' => 'rus'
                          }])
  end
end
