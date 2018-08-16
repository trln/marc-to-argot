# coding: utf-8
require 'spec_helper'
describe MarcToArgot::Macros::UNC::ResourceType do
  include Util::TrajectRunTest
  let(:archives1) { run_traject_json('unc', 'archives1', 'mrc') }
  let(:archives2) { run_traject_json('unc', 'archives2', 'mrc') }
  let(:archives3) { run_traject_json('unc', 'archives3', 'mrc') }
  let(:archives4) { run_traject_json('unc', 'archives4', 'mrc') }
  let(:archives5) { run_traject_json('unc', 'archives5', 'mrc') }
  let(:corpus1) { run_traject_json('unc', 'corpus1', 'mrc') }
  let(:thesis1) { run_traject_json('unc', 'thesis1', 'mrc') }
  let(:thesis2) { run_traject_json('unc', 'thesis2', 'mrc') }
  let(:thesis3) { run_traject_json('unc', 'thesis3', 'mrc') }
  let(:manuscript1) { run_traject_json('unc', 'manuscript1', 'mrc') }
  let(:stats1) { run_traject_json('unc', 'stats1', 'mrc') }
  let(:stats2) { run_traject_json('unc', 'stats2', 'mrc') }
  let(:stats_not1) { run_traject_json('unc', 'stats_not1', 'mrc') }
  
  context 'LDR/06 (rec type) is computer file (m)' do
    context 'AND 008/26 (type of computer file) is numeric data (a)' do
      it '(UNC) resource_type will include Dataset -- Statistical' do
        a = stats1['resource_type']
        expect(a).to include('Dataset -- Statistical')
      end
    end
    context 'AND 008/26 (type of computer file) is document (d)' do
      context 'AND 006/00 (additional format) is language material (a)' do
        context 'AND 336 contains dataset OR cod' do
          it '(UNC) resource_type will include Dataset -- Statistical' do
            a = corpus1['resource_type']
            expect(a).to include('Text corpus')
          end
        end
      end
    end
  end
  
  context 'LDR/06 (rec type) is manuscript language material (t)' do
    context 'AND 008/24-27 (nature of contents) does not contain m (thesis)' do
      context 'AND 502 field present' do 
        it '(UNC) resource_type = Thesis/Dissertation' do
          a = thesis2['resource_type']
          expect(a).to eq(['Thesis/Dissertation'])
        end
      end

      context 'AND 502 field NOT present' do 
        it '(UNC) resource_type = Archival and manuscript material' do
          a = manuscript1['resource_type']
          expect(a).to eq(['Archival and manuscript material'])
        end
      end
    end
    
    context 'AND 008/24-27 (nature of contents) includes  m (thesis)' do
      context 'AND 502 field present' do 
        it '(UNC) resource_type = Thesis/Dissertation' do
          a = thesis3['resource_type']
          expect(a).to eq(['Thesis/Dissertation'])
        end
      end

      context 'AND 502 field NOT present' do
        it '(UNC) resource_type = Thesis/Dissertation and Book' do
          a = thesis1['resource_type']
          expect(a).to eq(['Thesis/Dissertation', 'Book'])
        end
      end
    end
  end

  context 'LDR/08 (archival control) = a' do
    context 'AND LDR/07 (bib level) is c (collection)' do
      it '(UNC) resource_type = Archival and manuscript material' do
        a = archives1['resource_type']
        expect(a).to eq(['Archival and manuscript material'])
      end

      context 'AND LDR/06 (rec type) is music sound recording (j)' do
        it '(UNC) resource_type = Archival and manuscript material AND Music recording' do
          a = archives3['resource_type'].sort
          expect(a).to eq(['Archival and manuscript material', 'Music recording'])
        end
      end
      context 'AND LDR/06 (rec type) is 2-d non-projectable graphic (k)' do
        it '(UNC) resource_type = Archival and manuscript material AND Image' do
          a = archives4['resource_type'].sort
          expect(a).to eq(['Archival and manuscript material', 'Image'])
        end
      end
      context 'AND LDR/06 (rec type) is manuscript language material (t)' do
        it '(UNC) resource_type = Archival and manuscript material' do
          a = archives5['resource_type']
          expect(a).to eq(['Archival and manuscript material'])
        end
      end
    end

    context 'LDR/07 (bib level) is d (subunit)' do
      it '(UNC) resource_type = Archival and manuscript material' do
        a = archives1['resource_type']
        expect(a).to eq(['Archival and manuscript material'])
      end
    end
  end

  context '006/00 (form) is computer file (m)' do
    context 'AND 006/09 (type of computer file) is numeric data (a)' do
      it '(UNC) resource_type will include Dataset -- Statistical' do
        a = stats2['resource_type']
        expect(a).to include('Dataset -- Statistical')
      end

    end
  end

  context 'BOOK workform' do
    context 'AND 008/24-27 (nature of contents) contains s (statistics)' do
      context 'AND no further coding suggesting work actually IS statistics' do
        it '(UNC) resource_type does NOT include Dataset -- Statistical' do
          a = stats_not1['resource_type']
          expect(a).to_not include('Dataset -- Statistical')
        end
      end
    end
  end


end
