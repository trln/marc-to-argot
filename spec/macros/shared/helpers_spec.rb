# coding: utf-8
require 'spec_helper'
#require 'marc'

describe MarcToArgot::Macros::Shared::Helpers do
  let(:idhelper) { Class.new.include(MarcToArgot::Macros::Shared::Helpers) }

  describe 'general helper methods' do

    describe 'subfields_present' do
      subject { idhelper.new }

      it 'when subfields are a, q, and q => ["a", "q", "q"]' do
        field = MARC::DataField.new('020', ' ', ' ',
                                    MARC::Subfield.new('a', '1426217986 ('),
                                    MARC::Subfield.new('q', 'hardcover ;'),
                                    MARC::Subfield.new('q', 'alkaline paper)'))
        expect(subject.subfields_present(field)).to eq(['a', 'q', 'q'])
      end
    end

    describe 'subfield_count_map' do
      subject { idhelper.new }

      it 'when subfields are a, q, and q => {"a" => 1, "q" => 2}' do
        field = MARC::DataField.new('020', ' ', ' ',
                                    MARC::Subfield.new('a', '1426217986 ('),
                                    MARC::Subfield.new('q', 'hardcover ;'),
                                    MARC::Subfield.new('q', 'alkaline paper)'))
        expect(subject.subfield_count_map(field)).to eq({"a" => 1, "q" => 2})
      end
    end

    describe 'get_data_source_code' do
      subject { idhelper.new }

      it 'when $2 = isni' do
        field = MARC::DataField.new('024', '7', ' ',
                                    MARC::Subfield.new('a', '1426217986 ('),
                                    MARC::Subfield.new('q', 'hardcover ;'),
                                    MARC::Subfield.new('2', 'isni'))
        expect(subject.get_data_source_code(field)).to eq('isni')
      end

      it 'when $2 = isni AND viaf' do
        field = MARC::DataField.new('024', '7', ' ',
                                    MARC::Subfield.new('a', '1426217986 ('),
                                    MARC::Subfield.new('q', 'hardcover ;'),
                                    MARC::Subfield.new('2', 'isni'),
                                    MARC::Subfield.new('2', 'viaf'))
        expect(subject.get_data_source_code(field)).to eq('isni')
      end

      it 'when no $2' do
        field = MARC::DataField.new('024', '7', ' ',
                                    MARC::Subfield.new('a', '1426217986 ('),
                                    MARC::Subfield.new('q', 'hardcover ;'))
        expect(subject.get_data_source_code(field)).to eq(nil)
      end
    end
  end

  describe 'ID-related helper methods' do

    describe 'extract_identifier' do
      subject { idhelper.new }

      it '"123456" => "123456"' do
        expect(subject.extract_identifier('123456')).to eq('123456')
      end

      it '"123456 (abc)" => "123456"' do
        expect(subject.extract_identifier("123456 (abc)")).to eq('123456')
      end

      it '"123456 abc" => "123456 abc"' do
        expect(subject.extract_identifier("123456 abc")).to eq('123456 abc')
      end

      it '"(123456)" => "(123456)"' do
        expect(subject.extract_identifier("(123456)")).to eq('(123456)')
      end

      it '"(123456) (abc)" => "(123456)"' do
        expect(subject.extract_identifier("(123456) (abc)")).to eq('(123456)')
      end
    end

    describe 'extract_qualifier' do
      subject { idhelper.new }

      it '"123456" => nil' do
        expect(subject.extract_qualifier('123456')).to eq(nil)
      end

      it '"123456 (abc)" => "abc"' do
        expect(subject.extract_qualifier('123456 (abc)')).to eq('abc')
      end

      it '"123456 abc" => nil' do
        expect(subject.extract_qualifier('123456 abc')).to eq(nil)
      end

      it '"(123456)" => nil' do
        expect(subject.extract_qualifier('(123456)')).to eq(nil)
      end

      it '"(123456) (abc)" => "abc"' do
        expect(subject.extract_qualifier('(123456) (abc)')).to eq('abc')
      end
    end

    describe 'split_identifier_and_qualifier' do
      subject { idhelper.new }


      it '"123456" => ["123456"]' do
        expect(subject.split_identifier_and_qualifier('123456')).to eq(['123456'])
      end
      it '"123456 (abc)" => ["123456", "abc"]' do
        expect(subject.split_identifier_and_qualifier('123456 (abc)')).to eq(['123456', 'abc'])
      end

      it '"123456 abc" => ["123456 abc"]' do
        expect(subject.split_identifier_and_qualifier('123456 abc')).to eq(['123456 abc'])
      end

      it '"(123456)" => ["123456"]' do
        expect(subject.split_identifier_and_qualifier('(123456)')).to eq(['123456'])
      end

      it '"(123456) (abc)" => ["123456", "abc"]' do
        expect(subject.split_identifier_and_qualifier('(123456) (abc)')).to eq(['123456', 'abc'])
      end
    end

    describe 'remove_parentheses' do
      subject { idhelper.new }

      it '"(abc)" => "abc"' do
        expect(subject.remove_parentheses('(abc)')).to eq('abc')
      end

      it '"(abc) (123)" => "abc 123"' do
        expect(subject.remove_parentheses('(abc) (123)')).to eq('abc 123')
      end
    end

    describe 'qualifier_extracted_or_q' do
      subject { idhelper.new }

      it 'returns value from $q if present' do
        field = MARC::DataField.new('020',' ',' ',
                                    MARC::Subfield.new('a', '123456789X'),
                                    MARC::Subfield.new('q', '(pbk.)'))
        sf = MARC::Subfield.new('q', '(pbk.)')
        expect(subject.qualifier_extracted_or_q(field, sf)).to eq('pbk.')
      end
    end

    describe 'gather_qualifiers' do
      subject { idhelper.new }

      it 'gets from $a and $z' do
        field = MARC::DataField.new('024','8','1',
                                    MARC::Subfield.new('a', '123456789X (v. 1)'),
                                    MARC::Subfield.new('q', '(pbk.)'))
        expect(subject.gather_qualifiers(field, 'az', 'q')).to eq('v. 1; pbk.')
      end

      it 'gets from multiple $q' do
        field = MARC::DataField.new('020', ' ', ' ',
                                    MARC::Subfield.new('a', '1426217986 ('),
                                    MARC::Subfield.new('q', 'hardcover ;'),
                                    MARC::Subfield.new('q', 'alkaline paper)'))
        expect(subject.gather_qualifiers(field, 'az', 'q')).to eq('hardcover ; alkaline paper')
      end
    end

  end
end

