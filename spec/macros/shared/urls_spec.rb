# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::Shared::Helpers
include MarcToArgot::Macros::Shared::Urls

describe MarcToArgot::Macros::Shared::Urls do
  include Util

  def return_argot_url_field(rec)
    argot = run_traject_on_record('nccu', rec)
    url_field = argot['url']
    url_field = url_field.map{ |u| JSON.parse(u) } if url_field
  end

  describe 'url' do
    context 'when $u is repeated in a given 856' do
      it '(MTA) extracts only the first $u' do
        rec = make_rec
        rec << MARC::DataField.new('856', '4', '0', ['u', 'http://this.org'], ['u', 'http://that.org'])
        url = return_argot_url_field(rec)
        expect(url[0]['href']).to eq('http://this.org')
        expect(url.size).to eq(1)
      end
    end

    context 'when there is NO $u in 856' do
      it '(MTA) no url element output' do
        rec = make_rec
        rec << MARC::DataField.new('856', '4', '0', ['z', 'http://this.org'], ['y', 'http://that.org'])
        url = return_argot_url_field(rec)
        expect(url).to be_nil
      end
    end

    context 'when 856 field is repeated in record' do
      it '(MTA) output multiple url field elements' do
        rec = make_rec
        rec << MARC::DataField.new('856', '4', '0', ['u', 'http://this.org'])
        rec << MARC::DataField.new('856', '4', '0', ['u', 'http://that.org'])
        url = return_argot_url_field(rec)
        expect(url.size).to eq(2)
      end
    end

    context 'when there is no 856 field in record' do
      it '(MTA) no url field output' do
        rec = make_rec
        url = return_argot_url_field(rec)
        expect(url).to be_nil
      end
    end

    context 'When 856$y present' do
      it '(MTA) writes $y content to url[text]' do
        rec = make_rec
        rec << MARC::DataField.new('856', '4', '0', ['u', 'http://this.org'], ['y', 'link text here'])
        url = return_argot_url_field(rec)
        expect(url[0]['text']).to eq('link text here')
      end
    end
    
    context 'When 856$3 present' do
      it '(MTA) writes $3 content to url[note]' do
        rec = make_rec
        rec << MARC::DataField.new('856', '4', '0', ['u', 'http://this.org'], ['3', 'v. 1'])
        url = return_argot_url_field(rec)
        expect(url[0]['note']).to eq('v. 1')
      end
    end
  end

  describe 'url_type_value' do
    context 'When $3 contains thumbnail' do
      it '(MTA) url[type] = thumbnail' do
        field = MARC::DataField.new('856', '4', ' ', ['u', 'uri'], ['3', 'Thumbnail image'])
        v = url_type_value(field)
        expect(v).to eq('thumbnail')
      end
    end
    context 'When $3 contains finding aid' do
      it '(MTA) url[type] = findingaid' do
        field = MARC::DataField.new('856', '4', ' ', ['u', 'uri'], ['3', 'Finding aid:'])
        v = url_type_value(field)
        expect(v).to eq('findingaid')
      end
    end

    context 'When no special $3 value present' do
      context 'when i2 = 0' do
        it '(MTA) url[type] = fulltext' do
          field = MARC::DataField.new('856', '4', '0', ['u', 'uri'])
          v = url_type_value(field)
          expect(v).to eq('fulltext')
        end
      end
      context 'when i2 = 1' do
        it '(MTA) url[type] = fulltext' do
          field = MARC::DataField.new('856', '4', '1', ['u', 'uri'])
          v = url_type_value(field)
          expect(v).to eq('fulltext')
        end
      end
      context 'when i2 = 2 and no special $3 value present' do
        it '(MTA) url[type] = related' do
          field = MARC::DataField.new('856', '4', '2', ['u', 'uri'], ['3', 'Errata'])
          v = url_type_value(field)
          expect(v).to eq('related')
        end
      end
      context 'when i2 = 8' do
        it '(MTA) url[type] = other' do
          field = MARC::DataField.new('856', '4', '8', ['u', 'uri'], ['3', 'Errata'])
          v = url_type_value(field)
          expect(v).to eq('other')
        end
      end
      context 'when i2 = blank' do
        it '(MTA) url[type] = other' do
          field = MARC::DataField.new('856', '4', ' ', ['u', 'uri'], ['3', 'Errata'])
          v = url_type_value(field)
          expect(v).to eq('other')
        end
      end
    end
  end


  describe 'url_for_finding_aid?' do
    it 'returns true if 856$3 includes "finding aid"' do
      f1 = MARC::DataField.new('856', '4', '2', ['u', 'http://this.org'], ['3', 'finding aid'])
      f2 = MARC::DataField.new('856', '4', '2', ['u', 'http://this.org'], ['3', 'Finding Aid '])
      f3 = MARC::DataField.new('856', '4', '2', ['u', 'http://this.org'], ['3', 'Link to Finding aid'])
      f4 = MARC::DataField.new('856', '4', '2', ['u', 'http://this.org'], ['3', 'Finding aid:'])
      expect(url_for_finding_aid?(f1)).to eq(true)
      expect(url_for_finding_aid?(f2)).to eq(true)
      expect(url_for_finding_aid?(f3)).to eq(true)
      expect(url_for_finding_aid?(f4)).to eq(true)
    end

    it 'otherwise, returns false' do
      f1 = MARC::DataField.new('856', '4', '2', ['u', 'http://this.org'])
      f2 = MARC::DataField.new('856', '4', '2', ['u', 'http://this.org'], ['3', 'Thumbnail'])
      expect(url_for_finding_aid?(f1)).to eq(false)
      expect(url_for_finding_aid?(f2)).to eq(false)
    end
  end

end
