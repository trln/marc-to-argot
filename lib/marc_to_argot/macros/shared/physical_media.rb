module MarcToArgot
  module Macros
    module Shared
      module PhysicalMedia
        ################################################################
        # Physical Media Macros
        ################################################################

        def physical_media
          lambda do |rec, acc|
            acc.concat PhysicalMediaClassifier.new(rec).media
          end
        end

        class PhysicalMediaClassifier
          attr_reader :record

          def initialize(rec)
            @record = rec
          end

          def media
            media = []

            media << 'Art reproduction' if art_reproduction?
            media << 'Art' if art?
            media << 'Audiocassette tape' if audiocassette_tape?
            media << 'Blu-ray' if blu_ray?
            media << 'Braille or other tactile material' if braille?
            media << 'CD' if cd?
            media << 'Chart' if chart?
            media << 'Diskette' if diskette?
            media << 'DVD' if dvd?
            media << 'E-reader or player' if e_reader?
            media << 'E-reader or player > Kindle' if e_reader_kindle?
            media << 'E-reader or player > Nook' if e_reader_nook?
            media << 'E-reader or player > Playaway device' if e_reader_playaway_device?
            media << '8 mm film' if film_08_mm?
            media << '9.5 mm film' if film_09_5_mm?
            media << '16 mm film' if film_16_mm?
            media << '28 mm film' if film_28_mm?
            media << '35 mm film' if film_35_mm?
            media << '70 mm film' if film_70_mm?
            media << 'Super 8 mm film' if film_super_08_mm?
            media << 'Flash card' if flash_card?
            media << 'Globe' if globe?
            media << 'Large print' if large_print?
            media << 'Laserdisc' if laserdisc?
            media << 'Microform' if microform?
            media << 'Microform > Microfiche' if microform_microfiche?
            media << 'Microform > Microfilm' if microform_microfilm?
            media << 'Microform > Microopaque' if microform_microopaque?
            media << 'Photograph/picture' if photograph_picture?
            media << 'Photographic negative' if photographic_negative?
            media << 'Postcard' if postcard?
            media << 'Poster' if poster?
            media << 'Print' if print?
            media << '7" record' if record_07_inch?
            media << '10" record' if record_10_inch?
            media << '12" record' if record_12_inch?
            media << '33 1/3 rpm record' if record_33_33_rpm?
            media << '45 rpm record' if record_45_rpm?
            media << '78 rpm record' if record_78_rpm?
            media << 'Shellac record' if record_shellac?
            media << 'Vinyl record' if record_vinyl?
            media << 'Remote-sensing image' if remote_sensing_image?
            media << 'Remote-sensing image > Meteorological' if rsi_meteorological?
            media << 'Remote-sensing image > Mixed uses' if rsi_mixed_uses?
            media << 'Remote-sensing image > Space observing' if rsi_space_observing?
            media << 'Remote-sensing image > Surface observing' if rsi_surface_observing?
            media << 'Sheet' if sheet?
            media << 'Slides' if slides?
            media << 'Technical drawing' if technical_drawing?
            media << 'Videocassette (8 mm)' if videocassette_08_mm?
            media << 'Videocassette (Beta)' if videocassette_beta?
            media << 'Videocassette (D-2)' if videocassette_d2?
            media << 'Videocassette (Hi-8 mm)' if videocassette_hi_08_mm?
            media << 'Videocassette (U-matic)' if videocassette_umatic?
            media << 'Videocassette (M-II)' if videocassette_mii?
            media << 'Videocassette (VHS)' if videocassette_vhs?
            media << 'Videodisc (CED)' if videodisc_ced?
            media << 'Videoreel (EIAJ)' if videoreel_eiaj?
            media << 'Videoreel (Quadruplex)' if videoreel_quadruplex?
            media << 'Videoreel (Type C)' if videoreel_type_c?

            media
          end

          def art_reproduction?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'k' &&
              field.value.byteslice(1) == 'f'
            end
          end

          def art?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'k' &&
              %w[c d e j q].include?(field.value.byteslice(1))
            end
          end

          def audiocassette_tape?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 's' &&
              field.value.byteslice(1) == 's'
            end
          end

          def blu_ray?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'v' &&
              field.value.byteslice(1) == 'd' &&
              field.value.byteslice(4) == 's'
            end
          end

          def braille?
            record.fields('007').find do |field|
              (field.value.byteslice(0) == 't' &&
              field.value.byteslice(1) == 'c') ||
              field.value.byteslice(0) == 'f'
            end
          end

          def cd?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 's' &&
              field.value.byteslice(6) == 'g'
            end
          end

          def chart?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'k' &&
              field.value.byteslice(1) == 'n'
            end
          end

          def diskette?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'c' &&
              field.value.byteslice(1) == 'j'
            end
          end

          def dvd?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'v' &&
              field.value.byteslice(1) == 'd' &&
              field.value.byteslice(4) == 'v'
            end
          end

          # Redefine in local macros if needed.
          # See duke_macros.rb PhysicalMedia::PhysicalMediaClassifier for example.
          def e_reader?; end
          def e_reader_kindle?; end
          def e_reader_nook?; end
          def e_reader_playaway_device?; end

          def film_08_mm?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'g' &&
              field.value.byteslice(7) == 'a'
            end
          end

          def film_09_5_mm?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'g' &&
              field.value.byteslice(7) == 'c'
            end
          end

          def film_16_mm?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'g' &&
              field.value.byteslice(7) == 'd'
            end
          end

          def film_28_mm?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'g' &&
              field.value.byteslice(7) == 'e'
            end
          end

          def film_35_mm?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'g' &&
              field.value.byteslice(7) == 'f'
            end
          end

          def film_70_mm?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'g' &&
              field.value.byteslice(7) == 'g'
            end
          end

          def film_super_08_mm?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'g' &&
              field.value.byteslice(7) == 'b'
            end
          end

          def flash_card?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'k' &&
              field.value.byteslice(1) == 'o'
            end
          end

          def globe?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'd'
            end
          end

          def large_print?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 't' &&
              field.value.byteslice(1) == 'b'
            end
          end

          def laserdisc?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'v' &&
              field.value.byteslice(1) == 'd' &&
              field.value.byteslice(4) == 'g'
            end
          end

          def microform?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'h'
            end
          end

          def microform_microfilm?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'h' &&
              %w[b c d h j].include?(field.value.byteslice(1))
            end
          end

          def microform_microfiche?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'h' &&
              %w[e f].include?(field.value.byteslice(1))
            end
          end

          def microform_microopaque?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'h' &&
              field.value.byteslice(1) == 'g'
            end
          end

          def photograph_picture?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'k' &&
              %w[h i s r v].include?(field.value.byteslice(1))
            end
          end

          def photographic_negative?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'k' &&
              field.value.byteslice(1) == 'g'
            end
          end

          def postcard?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'k' &&
              field.value.byteslice(1) == 'p'
            end
          end

          def poster?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'k' &&
              field.value.byteslice(1) == 'k'
            end
          end

          # The proposed method of marking items as Print (see commented out code)
          # doesn't seem to work for a majority of cases where I know the record is
          # for a print item. I've duplicated how the out of the box Traject format
          # classifier determines if a record is "print." Seems OK. Can revisit.
          def print?
            # record.fields('007').find do |field|
            #   field.value.byteslice(0) == 't'
            # end
            rda338 = record.find_all do |field|
              field.tag == "338" && field['2'] == "rdacarrier"
            end

            if rda338.length > 0
              rda338.find do |field|
                field.subfields.find do |sf|
                  (sf.code == "a" && %w{volume card sheet}.include?(sf.value)) ||
                  (sf.code == "b" && %w{nc no nb}.include?(sf.value))
                end
              end
            else
              (((a245 = record['245']) && a245['h'] && a245['h'].downcase) || "".length) == 0
            end
          end

          def record_07_inch?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 's' &&
              field.value.byteslice(1) == 'd' &&
              field.value.byteslice(6) == 'c'
            end
          end

          def record_10_inch?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 's' &&
              field.value.byteslice(1) == 'd' &&
              field.value.byteslice(6) == 'd'
            end
          end

          def record_12_inch?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 's' &&
              field.value.byteslice(1) == 'd' &&
              field.value.byteslice(6) == 'e'
            end
          end

          def record_33_33_rpm?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 's' &&
              field.value.byteslice(1) == 'd' &&
              field.value.byteslice(3) == 'b'
            end
          end

          def record_45_rpm?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 's' &&
              field.value.byteslice(1) == 'd' &&
              field.value.byteslice(3) == 'c'
            end
          end

          def record_78_rpm?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 's' &&
              field.value.byteslice(1) == 'd' &&
              field.value.byteslice(3) == 'd'
            end
          end

          def record_shellac?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 's' &&
              field.value.byteslice(1) == 'd' &&
              field.value.byteslice(10) == 's'
            end
          end

          # TODO: Check this.
          def record_vinyl?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 's' &&
              field.value.byteslice(1) == 'd' &&
              field.value.byteslice(6) != 'g' &&
              field.value.byteslice(10) != 's'
            end
          end

          def remote_sensing_image?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'r'
            end
          end

          def rsi_meteorological?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'r' &&
              field.value.byteslice(7) == 'a'
            end
          end

          def rsi_mixed_uses?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'r' &&
              field.value.byteslice(7) == 'm'
            end
          end

          def rsi_space_observing?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'r' &&
              field.value.byteslice(7) == 'c'
            end
          end

          def rsi_surface_observing?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'r' &&
              field.value.byteslice(7) == 'b'
            end
          end

          # TODO: Check this mapping.
          def sheet?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'd' &&
              %w[g j k s].include?(field.value.byteslice(1))
            end
          end

          def slides?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'g' &&
              field.value.byteslice(1) == 's'
            end
          end

          def technical_drawing?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'k' &&
              field.value.byteslice(1) == 'l'
            end
          end

          def videocassette_08_mm?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'v' &&
              field.value.byteslice(1) == 'f' &&
              field.value.byteslice(4) == 'p'
            end
          end

          def videocassette_beta?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'v' &&
              field.value.byteslice(1) == 'f' &&
              %w[a i j].include?(field.value.byteslice(4))
            end
          end

          def videocassette_d2?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'v' &&
              field.value.byteslice(1) == 'f' &&
              field.value.byteslice(4) == 'o'
            end
          end

          def videocassette_hi_08_mm?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'v' &&
              field.value.byteslice(1) == 'f' &&
              field.value.byteslice(4) == 'q'
            end
          end

          def videocassette_umatic?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'v' &&
              field.value.byteslice(1) == 'f' &&
              field.value.byteslice(4) == 'c'
            end
          end

          def videocassette_mii?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'v' &&
              field.value.byteslice(1) == 'f' &&
              field.value.byteslice(4) == 'm'
            end
          end

          def videocassette_vhs?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'v' &&
              field.value.byteslice(1) == 'f' &&
              %w[b k].include?(field.value.byteslice(4))
            end
          end

          def videodisc_ced?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'v' &&
              field.value.byteslice(1) == 'd' &&
              field.value.byteslice(4) == 'h'
            end
          end

          def videoreel_eiaj?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'v' &&
              field.value.byteslice(1) == 'r' &&
              field.value.byteslice(4) == 'd'
            end
          end

          def videoreel_quadruplex?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'v' &&
              field.value.byteslice(1) == 'r' &&
              field.value.byteslice(4) == 'f'
            end
          end

          def videoreel_type_c?
            record.fields('007').find do |field|
              field.value.byteslice(0) == 'v' &&
              field.value.byteslice(1) == 'r' &&
              field.value.byteslice(4) == 'e'
            end
          end
        end
      end
    end
  end
end
