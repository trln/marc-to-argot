# coding: utf-8
require 'spec_helper'

describe MarcToArgot::Macros::Shared::Names do
  include Util::TrajectRunTest

  let(:names01) { run_traject_json('unc', 'names01', 'mrc') }
  let(:names02) { run_traject_json('unc', 'names02', 'mrc') }
  let(:names03) { run_traject_json('unc', 'names03', 'mrc') }
  let(:names04) { run_traject_json('unc', 'names04', 'mrc') }
  let(:names05) { run_traject_json('unc', 'names05', 'mrc') }
  let(:names06) { run_traject_json('unc', 'names06', 'mrc') }
  let(:names07) { run_traject_json('unc', 'names07', 'mrc') }
  let(:names08) { run_traject_json('unc', 'names08', 'mrc') }
  let(:names09) { run_traject_json('unc', 'names09', 'mrc') }
  let(:names10) { run_traject_json('unc', 'names10', 'mrc') }
  let(:names11) { run_traject_json('unc', 'names11', 'mrc') }
  let(:names12) { run_traject_json('unc', 'names12', 'mrc') }

  it '(MTA) sets names, prioritizing director type over creator type' do
    result = names01['names']
    expect(result).to eq(
                        [{'name'=>'Key, Keegan-Michael',
                          'type'=>'creator'},
                         {'name'=>'Birbiglia, Mike',
                          'rel'=>['director', 'screenwriter', 'producer', 'actor'],
                          'type'=>'director'},
                         {'name'=>'Jacobs, Gillian, 1982-',
                          'rel'=>['actor'],
                          'type'=>'contributor'},
                         {'name'=>'Micucci, Kate',
                          'rel'=>['actor'],
                          'type'=>'contributor'},
                         {'name'=>'Sagher, Tami',
                          'rel'=>['actor'],
                          'type'=>'contributor'}]
    )
  end

  it '(MTA) sets names, setting editor over contributor, deduping relators' do
    result = names02['names']
    expect(result).to eq(
                        [{'name'=>'Jerome, Saint, -419 or 420',
                          'rel'=>['author'],
                          'type'=>'creator'},
                         {'name'=>'Canellis, Aline',
                          'rel'=>['editor', 'translator'],
                          'type'=>'editor'}
                        ])
  end

  it '(MTA) sets names, setting 1XX to non-creator type based on relator' do
    result = names03['names']
    expect(result).to eq(
                        [{'name'=>'Robeson, Paul, 1898-1976',
                          'rel'=>['performer'],
                          'type'=>'contributor'},
                         {'name'=>'Booth, Alan, 1924-1996',
                          'rel'=>['performer'],
                          'type'=>'contributor'}
                        ])
  end

  it '(MTA) sets names, multiple creators, initial followed by retained period at end of name' do
    result = names04['names']
    expect(result).to eq(
                        [{'name'=>'Bériot, Ch. de (Charles), 1802-1870',
                          'rel'=>['composer'],
                          'type'=>'creator'},
                         {'name'=>'Labarre, Théodore, 1805-1870',
                          'rel'=>['composer'],
                          'type'=>'creator'},
                         {'name'=>'Sheldon, Henry K.',
                          'rel'=>['former owner', 'compiler'],
                          'type'=>'creator'}
                        ])
  end

  it '(MTA) sets names, keeping UNC $5, some names NOT mapping to author facet' do
    result = names05['names']
    expect(result).to eq(
                        [{'name'=>'Wilson, James, 1779-1845',
                          'rel'=>['author'],
                          'type'=>'creator'},
                          {'name'=>'Showell, John Whitehouse',
                          'rel'=>['printer'],
                          'type'=>'manufacturer'},
                          {'name'=>'Hutchinson, Elizabeth, 1820-1905',
                          'rel'=>['former owner', 'autographer'],
                          'type'=>'owner'},
                          {'name'=>'Hutchinson, Sara, 1775-1835',
                          'rel'=>['inscriber'],
                          'type'=>'other'},
                          {'name'=>'Reed, Mark L.',
                          'rel'=>['former owner'],
                          'type'=>'owner'}
                        ])
  end

  it '(MTA) sets names, discarding fields with non-whitelisted $5' do
    result = names06['names']
    expect(result).to eq(
                        [{'name'=>'Merrill, James, 1926-1995',
                          'rel'=>['author'],
                          'type'=>'creator'}
                        ])
  end

  it '(MTA) sets names, including uncontrolled name fields' do
    result = names07['names']
    expect(result).to eq(
                        [{'name'=>'Lampe, Angela',
                          'rel'=>['editor'],
                          'type'=>'editor'},
                         {'name'=>'Musée national d\'art moderne (France)',
                          'rel'=>['host institution'],
                          'type'=>'other'},
                         {'name'=>'Baumgartner, Michael',
                          'rel'=>['conservator'],
                          'type'=>'uncategorized'},
                         {'name'=>'Haxthausen, Charles W.',
                          'rel'=>['conservator'],
                          'type'=>'uncategorized'},
                         {'name'=>'Hopfengart, Christine',
                          'rel'=>['conservator'],
                          'type'=>'uncategorized'}
                        ])
  end

  it '(MTA) sets names, handling 7XX with no relator term or code' do
    result = names08['names']
    expect(result).to eq(
                        [{'name'=>'Telemann, Georg Philipp, 1681-1767',
                          'type'=>'creator'},
                         {'name'=>'Bach, Johann Sebastian, 1685-1750',
                          'type'=> 'no_rel'},
                         {'name'=>'Schröder, Otto, 1860-1946',
                          'rel'=>['editor'],
                          'type'=>'editor'}
                        ])
  end

  it '(MTA) sets names, handling relator terms that don\'t map to a category' do
    result = names09['names']
    expect(result).to eq(
                        [{'name'=>'Hincker, Louis',
                          'rel'=>['editor'],
                          'type'=>'editor'},
                         {'name'=>'Amselle, Frédérique',
                          'rel'=>['ditor'],
                          'type'=>'uncategorized'},
                         {'name'=>'Huftier, Arnaud',
                          'rel'=>['ditor'],
                          'type'=>'uncategorized'},
                         {'name'=>'Lacheny, Marc',
                          'rel'=>['editor'],
                          'type'=>'editor'},
                         {'name'=>'Université de Valenciennes et du Hainaut-Cambrésis',
                          'rel'=>['host institution'],
                          'type'=>'other'}
                        ])
  end

  it '(MTA) sets names, handling sole relator code without mapping to term' do
    result = names10['names']
    expect(result).to eq(
                        [{'name'=>'Hincker, Louis',
                          'type' => 'no_rel'}
                        ])
  end

  it '(MTA) sets names, handling multiple relator codes when one is without mapping to term' do
    result = names11['names']
    expect(result).to eq(
                        [{'name'=>'Hincker, Louis',
                          'rel'=>['translator'],
                          'type'=>'contributor'}
                        ])
  end

  it '(MTA) sets names from 1XX that include $t' do
    result = names12['names']
    expect(result).to eq(
                        [{'name'=>'France',
                          'type'=>'creator'},
                         {'name'=>'Spence, Thomas, 1750-1814',
                          'rel'=>['writer of preface'],
                          'type'=>'contributor'}
                        ])
  end
end
