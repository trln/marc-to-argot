require 'spec_helper'

describe MARC::Record do

  def create_rec
    rec = MARC::Record.new
    cf008val = ''
    40.times { cf008val << ' ' }
    rec << MARC::ControlField.new('008', cf008val)
    rec
  end

  describe '.date_type' do
    it 'returns DateType from 008' do
      rec = create_rec
      rec['008'].value[6] = 's'

      result = rec.date_type
      expect(result).to eq('s')
    end

    it 'fails gracefully if no 008' do
      rec = MARC::Record.new

      result = rec.date_type
      expect(result).to be_nil
    end

    it 'fails gracefully if 008 has no byte 06' do
      rec = MARC::Record.new
      rec << MARC::ControlField.new('008', '   ')
      result = rec.date_type
      expect(result).to be_nil
    end

  end

  describe '.date1' do
    it 'returns Date1 (bytes 7-10) from 008' do
      rec = create_rec
      rec['008'].value[7..10] = '2018'

      result = rec.date1
      expect(result).to eq('2018')
    end
  end

  describe '.date2' do
    it 'returns Date1 (bytes 11-14) from 008' do
      rec = create_rec
      rec['008'].value[11..14] = '2007'

      result = rec.date2
      expect(result).to eq('2007')
    end
  end

end
