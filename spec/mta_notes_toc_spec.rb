# coding: utf-8
require 'spec_helper'
describe MarcToArgot do
  toc01 = JSON.parse( Util::TrajectRunTest.run_traject('unc', 'toc01') )

  it '(MTA) sets single TOC note with 1st ind = 0' do
    result = toc01['note_toc'][0]
    expect(result).to(
      eq({'value' => 'Tape 1. Pt. 1. Fernweh (The call of far away places, 1919)--Tape 2. Pt. 2. Die mitte der welt (The centre of the world, 1929)--Tape 3. Pt. 3. Weihnacht (The best Christmas ever, 1934)--Tape 4. Pt. 4. Reichshoherstrabe (The highway, 1938).', 'label' => ''})
    )
  end

end
