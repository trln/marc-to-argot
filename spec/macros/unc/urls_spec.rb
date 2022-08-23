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

  shared_examples '(UNC) a restricted url' do
    it '(UNC) #is_restricted? returns true' do
      expect(is_restricted?(subject)).to be true
    end

    it '(UNC) does not output restricted field' do
      rec = make_rec
      rec << MARC::DataField.new('856', '4', '0', ['u', subject])
      url = return_argot_url_field(rec)
      expect(url.first['restricted']).to be_nil
    end
  end

  shared_examples '(UNC) an unrestricted url' do
    it '(UNC) #is_restricted? returns false' do
      expect(is_restricted?(subject)).to be false
    end

    it '(UNC) writes out url[restricted] = false' do
      rec = make_rec
      rec << MARC::DataField.new('856', '4', '0', ['u', subject])
      url = return_argot_url_field(rec)
      expect(url.first['restricted']).to eq('false')
    end
  end

  shared_examples '(UNC) a proxied url' do
    it '(UNC) #is_proxied? returns true' do
      expect(is_proxied?(subject)).to be true
    end
  end

  shared_examples '(UNC) an unproxied url' do
    it '(UNC) #is_proxied? returns false' do
      expect(is_proxied?(subject)).to be false
    end
  end

  shared_examples '(UNC) a proxy-templatable url' do
    it '(UNC) #template_proxy returns the URL with a template parameter' do
      expect(template_proxy(subject)).to eq('{+proxyPrefix}https://blahblah')
    end
  end

  describe 'proxied url' do
    subject(:proxied_url) { 'http://libproxy.lib.unc.edu/login?url=https://blahblah' }
    it_behaves_like '(UNC) a restricted url'
    it_behaves_like '(UNC) a proxied url'
    it_behaves_like '(UNC) a proxy-templatable url'
  end

  describe 'alternate-format proxied url' do
    subject(:alt_proxied_url) { 'http://www-example-com.libproxy.lib.unc.edu/blahblah' }
    it_behaves_like '(UNC) a restricted url'
    it_behaves_like '(UNC) a proxied url'
  end

  describe 'law proxied url' do
    subject(:law_proxied_url) { 'http://lawlibproxy2.unc.edu:2048/login?url=https://blahblah' }
    it_behaves_like '(UNC) a restricted url'
    it_behaves_like '(UNC) a proxied url'
  end

  describe 'unproxied url' do
    context 'when unrestricted' do
      subject(:unproxied_url) { 'https://www.example.com' }
      it_behaves_like '(UNC) an unrestricted url'
      it_behaves_like '(UNC) an unproxied url'
    end

    context 'when on the list of restricted exceptions' do
      subject(:restricted_exception) { 'http://vb3lk7eb4t.search.serialssolutions.com/blahblah' }
      it_behaves_like '(UNC) a restricted url'
      it_behaves_like '(UNC) an unproxied url'
    end
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
    context 'when URL begins with a proxy prefix' do
      it '(UNC) returns true' do
        url = 'http://libproxy.lib.unc.edu/login?url=https://blahblah'
        v = is_proxied?(url)
        expect(v).to eq(true)
      end
    end

    context 'when URL does not use a UNC proxy' do
      it '(UNC) returns false' do
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
    context 'when URL includes an unproxied, restricted URL', :aggregate_failures do
      it '(UNC) returns true' do
        urls = %w[
          https://catalog.hathitrust.org/Record/001665338?signon=swle:urn:mace:incommon:unc.edu
          http://unc.kanopystreaming.com/blahblah
          https://unc.kanopy.com/blahblah
          http://vb3lk7eb4t.search.serialssolutions.com/blahblah
        ]
        urls.each { |url| expect(is_restricted?(url)).to be true }
      end
    end
    context 'when URL does NOT contain a restricted URL' do
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
