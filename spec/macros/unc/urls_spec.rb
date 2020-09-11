# coding: utf-8
require 'spec_helper'
include MarcToArgot::Macros::Shared::Helpers
include MarcToArgot::Macros::UNC::Urls

describe MarcToArgot::Macros::UNC::Urls do
  include Util

  def return_argot_url_field(rec)
    argot = run_traject_on_record('unc', rec)
    url_field = argot['url']
    url_field = url_field.map{ |u| JSON.parse(u) } if url_field
  end

  describe 'url_unc' do
    it '(UNC) writes url[type]' do
      rec = make_rec
      rec << MARC::DataField.new('856', '4', '0', ['u', 'http://this.org'])
      rec << MARC::DataField.new('856', '4', '2', ['u', 'http://that.io'], ['3', 'Finding aid'])
      url = return_argot_url_field(rec)
      expect(url[0]['type']).to eq('fulltext')
      expect(url[1]['type']).to eq('findingaid')
    end

    context 'When $3 present' do
    it '(UNC) writes url[note] from 856$3' do
      rec = make_rec
      rec << MARC::DataField.new('856', '4', '0', ['u', 'http://that.io'], ['3', 'In Spanish'])
      url = return_argot_url_field(rec)
      expect(url[0]['note']).to eq('In Spanish')
    end
    end

    context 'When $y present' do
    it '(UNC) writes url[text] from 856$y' do
      rec = make_rec
      rec << MARC::DataField.new('856', '4', '0', ['u', 'http://that.io'], ['y', 'link text here'])
      url = return_argot_url_field(rec)
      expect(url[0]['text']).to eq('link text here')
    end
    end

    context 'When $y NOT present and type = fulltext' do
    it '(UNC) writes default url[text]' do
      rec = make_rec
      rec << MARC::DataField.new('856', '4', '0', ['u', 'http://that.io'])
      rec << MARC::DataField.new('856', '4', '1', ['u', 'http://this.io'])
      url = return_argot_url_field(rec)
      expect(url[0]['text']).to eq('Available via the UNC-Chapel Hill Libraries')
      expect(url[1]['text']).to eq('Available via the UNC-Chapel Hill Libraries')
    end
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

    context 'when rec is non-shared filmfinder' do
      it '(UNC) does not use a proxy template' do
        rec = make_rec
        url = 'http://libproxy.lib.unc.edu/login?url=http://this.org'
        rec << MARC::DataField.new('856', '4', '0', ['u', url])
        rec << MARC::DataField.new('919', ' ', ' ', ['a', 'filmfinder'])
        argot_url = return_argot_url_field(rec)
        expect(argot_url.first['href']).to start_with('http://libproxy.lib.unc')
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
    it '(UNC) restriction detection is case-insensitive' do
      url = 'http://VB3LK7EB4T.search.serialssolutions.com/blahblah'
      v = is_restricted?(url)
      expect(v).to eq(true)
    end
    context 'when URL is proxied' do
      it '(UNC) returns true' do
        url = 'http://libproxy.lib.unc.edu/login?url=https://blahblah'
        v = is_restricted?(url)
        expect(v).to eq(true)
      end
    end
    context 'when a Kanopy URL', :aggregate_failures do
      it '(UNC) returns true' do
        url = 'http://unc.kanopystreaming.com/blahblah'
        v = is_restricted?(url)
        expect(v).to eq(true)

        https = 'https://unc.kanopy.com/blahblah'
        expect(is_restricted?(https)).to be true
      end
    end
    context 'when a Serials Solutions URL' do
      it '(UNC) returns true' do
        url = 'http://vb3lk7eb4t.search.serialssolutions.com/blahblah'
        v = is_restricted?(url)
        expect(v).to eq(true)
      end
    end
    context 'when URL uses UNC Incommon entityID' do
      it '(UNC) returns true' do
        url = 'https://catalog.hathitrust.org/Record/001665338?signon=swle:urn:mace:incommon:unc.edu'
        v = is_restricted?(url)
        expect(v).to eq(true)
      end
    end
    context 'when URL does NOT begin with restricted URL string' do
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
      expect(v).to eq('{+proxyPrefix}https://blahblah')
    end
  end
end
