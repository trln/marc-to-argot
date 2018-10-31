# coding: iso-8859-1
require 'spec_helper'
include MarcToArgot::Macros::Shared::Helpers
include MarcToArgot::Macros::UNC::Urls

describe MarcToArgot::Macros::UNC::Urls do
  include Util

  def make_rec
    rec = MARC::Record.new
    rec << MARC::ControlField.new('008', ' ' * 40)
    return rec
  end

  def return_argot_url_field(rec)
    argot = run_traject_on_record('unc', rec)
    url_field = argot['url']
    url_field = url_field.map{ |u| JSON.parse(u) } if url_field
  end

  describe 'url' do
    context 'when $u is repeated in a given 856' do
      it '(UNC) extracts only the first $u' do
        rec = make_rec
        rec << MARC::DataField.new('856', '4', '0', ['u', 'http://this.org'], ['u', 'http://that.org'])
        url = return_argot_url_field(rec)
        expect(url[0]['href']).to eq('http://this.org')
        expect(url.size).to eq(1)
      end
    end

    context 'when there is NO $u in 856' do
      it '(UNC) no url element output' do
        rec = make_rec
        rec << MARC::DataField.new('856', '4', '0', ['z', 'http://this.org'], ['y', 'http://that.org'])
        url = return_argot_url_field(rec)
        expect(url).to be_nil
      end
    end

    context 'when 856 field is repeated in record' do
      it '(UNC) output multiple url field elements' do
        rec = make_rec
        rec << MARC::DataField.new('856', '4', '0', ['u', 'http://this.org'])
        rec << MARC::DataField.new('856', '4', '0', ['u', 'http://that.org'])
        url = return_argot_url_field(rec)
        expect(url.size).to eq(2)
      end
    end

    context 'when there is no 856 field in record' do
      it '(UNC) no url field output' do
        rec = make_rec
        url = return_argot_url_field(rec)
        expect(url).to be_nil
      end
    end

    it '(UNC) writes url[type]' do
      rec = make_rec
      rec << MARC::DataField.new('856', '4', '0', ['u', 'http://this.org'])
      rec << MARC::DataField.new('856', '4', '2', ['u', 'http://that.io'], ['3', 'Thumbnail'])
      url = return_argot_url_field(rec)
      expect(url[0]['type']).to eq('fulltext')
      expect(url[1]['type']).to eq('thumbnail')
    end

    it '(UNC) writes url[text] appropriately given shared record status' do
      rec = make_rec
      rec << MARC::DataField.new('856', '4', '0', ['u', 'http://that.io'], ['3', 'In Spanish'])
      url = return_argot_url_field(rec)
      expect(url[0]['text']).to eq('In Spanish -- Available via the UNC-Chapel Hill Libraries')

      rec2 = make_rec
      rec2 << MARC::DataField.new('856', '4', '0', ['u', 'http://that.io'], ['3', 'In Spanish'])
      rec2 << MARC::DataField.new('919', ' ', ' ', ['a', 'aspanth'])
      url2 = return_argot_url_field(rec2)
      expect(url2[0]['text']).to eq('In Spanish')
    end

    context 'when url is for a restricted resource' do
      it '(UNC) does NOT write out url[restricted] (because the default value is true)' do
        rec = make_rec
        rec << MARC::DataField.new('856', '4', '0', ['u', 'http://unc.kanopystreaming.com/134'])
        url = return_argot_url_field(rec)
        expect(url[0]['restricted']).to be_nil
      end
    end
    context 'when url is for an unrestricted resource' do
      it '(UNC) writes out url[restricted] = false' do
        rec = make_rec
        rec << MARC::DataField.new('856', '4', '0', ['u', 'http://that.io'])
        url = return_argot_url_field(rec)
        expect(url[0]['restricted']).to eq('false')
      end
    end
  end

  describe 'normal_url_text' do
    context 'when $y present and no $3 present' do
      it '(UNC) sets url[text] from $y' do
        field = MARC::DataField.new('856', '4', '0', ['u', 'uri'], ['y', 'text'])
        v = normal_url_text(field)
        expect(v).to eq('text')
      end
    end
    context 'when $3 present and no $y present' do
      it '(UNC) sets url[text] from $3 and constant value, in that order, separated by \' -- \'' do
        field = MARC::DataField.new('856', '4', '0', ['u', 'uri'], ['3', 'label'])
        v = normal_url_text(field)
        expect(v).to eq('label -- Available via the UNC-Chapel Hill Libraries')
      end
    end
    context 'when $3 present and $y present' do
      it '(UNC) sets url[text] from $3 and $y, in that order, separated by \' -- \'' do
        rec = make_rec
        field = MARC::DataField.new('856', '4', '0', ['u', 'uri'], ['y', 'text'], ['3', 'label'])
        v = normal_url_text(field)
        expect(v).to eq('label -- text')
      end
    end
    context 'when NO $3 present and NO $y present' do
      it '(UNC) provides constant url[text]' do
        field = MARC::DataField.new('856', '4', '0', ['u', 'uri'])
        v = normal_url_text(field)
        expect(v).to eq('Available via the UNC-Chapel Hill Libraries')
      end
    end
  end

  describe 'shared_record_url_text' do
    context 'when $y present and no $3 present' do
      it '(UNC) does NOT set url[text] from $y' do
        field = MARC::DataField.new('856', '4', '0', ['u', 'uri'], ['y', 'text'])
        v = shared_record_url_text(field)
        expect(v).to be_nil
      end
    end
    context 'when $3 present and no $y present' do
      it '(UNC) sets url[text] from $3' do
        field = MARC::DataField.new('856', '4', '0', ['u', 'uri'], ['3', 'label'])
        v = shared_record_url_text(field)
        expect(v).to eq('label')
      end
    end
    context 'when $3 present and $y present' do
      it '(UNC) sets url[text] from $3' do
        field = MARC::DataField.new('856', '4', '0', ['u', 'uri'], ['y', 'text'], ['3', 'label'])
        v = shared_record_url_text(field)
        expect(v).to eq('label')
      end
    end
    context 'when NO $3 present and NO $y present' do
      it '(UNC) does NOT set url[text]' do
        field = MARC::DataField.new('856', '4', '0', ['u', 'uri'])
        v = shared_record_url_text(field)
        expect(v).to be_nil
      end
    end
  end

  describe 'url_type_value (this code lives in the shared URLs macro)' do
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
    context 'when i2 = 2 and $3 contains thumbnail' do
      it '(MTA) url[type] = thumbnail' do
        field = MARC::DataField.new('856', '4', '2', ['u', 'uri'], ['3', 'Thumbnail image'])
        v = url_type_value(field)
        expect(v).to eq('thumbnail')
      end
    end
    context 'when i2 = 2 and $3 contains finding aid' do
      it '(MTA) url[type] = findingaid' do
        field = MARC::DataField.new('856', '4', '2', ['u', 'uri'], ['3', 'Finding aid:'])
        v = url_type_value(field)
        expect(v).to eq('findingaid')
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

  describe 'is_proxied?' do
    context 'URL begins with http://libproxy.lib.unc.edu/login?url=' do
      it '(UNC) returns true' do
        url = 'http://libproxy.lib.unc.edu/login?url=https://blahblah'
        v = is_proxied?(url)
        expect(v).to eq(true)
      end
    end
    context 'URL does not begin with http://libproxy.lib.unc.edu/login?url=' do
      it '(UNC) returns nil value' do
        url = 'https://blahblah'
        v = is_proxied?(url)
        expect(v).to eq(false)
      end
    end
  end

  describe 'is_restricted?' do
    context 'URL is proxied' do
      it '(UNC) returns true' do
        url = 'http://libproxy.lib.unc.edu/login?url=https://blahblah'
        v = is_restricted?(url)
        expect(v).to eq(true)
      end
    end
    context 'URL begins with http://unc.kanopystreaming.com' do
      it '(UNC) returns true' do
        url = 'http://unc.kanopystreaming.com/blahblah'
        v = is_restricted?(url)
        expect(v).to eq(true)
      end
    end
    context 'URL begins with http://vb3lk7eb4t.search.serialssolutions.com' do
      it '(UNC) returns true' do
        url = 'http://vb3lk7eb4t.search.serialssolutions.com/blahblah'
        v = is_restricted?(url)
        expect(v).to eq(true)
      end
    end
    context 'URL does NOT begin with restricted URL string' do
      it '(UNC) returns nil value' do
        url = 'https://purl.fdlp.gov/GPO/gpo92270'
        v = is_restricted?(url)
        expect(v).to eq(false)
      end
    end
  end

  describe 'template_proxy' do
    it '(UNC) returns url with proxy prefix as a URL template parameter' do
      url = 'http://libproxy.lib.unc.edu/login?url=https://blahblah'
      v = template_proxy(url)
      expect(v).to eq('{proxyPrefix}https://blahblah')
    end
  end
end
