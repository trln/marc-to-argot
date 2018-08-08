module MarcToArgot
  module Macros
    module Shared
      module ResourceType
        ################################################################
        # resource type macros
        ################################################################

        def resource_type
          lambda do |rec, acc|
            acc.concat ResourceTypeClassifier.new(rec).formats
          end
        end

        class ResourceTypeClassifier
          attr_reader :record

          def initialize(rec)
            @record = rec
          end

          def formats
            formats = []

            formats << 'Archival and manuscript material' if archival_manuscript?
            formats << 'Audiobook' if audiobook?
            formats << 'Book' if book?
            formats << 'Database' if database?
            formats << 'Dataset -- Statistical' if dataset_statistical?
            formats << 'Game' if game?
            unless from_university_press?
              formats << 'Government publication' if government_publication?
            end
            formats << 'Image' if image?
            formats << 'Journal, Magazine, or Periodical' if journal_magazine_periodical?
            formats << 'Kit' if kit?
            formats << 'Map' if map?
            formats << 'Music recording' if music_recording?
            formats << 'Music score' if music_score?
            formats << 'Newspaper' if newspaper?
            formats << 'Non-musical sound recording' if non_musical_sound_recording?
            formats << 'Object' if object?
            formats << 'Software/multimedia' if software_multimedia?
            formats << 'Thesis/Dissertation' if thesis_dissertation?
            formats << 'Video' if video?
            formats << 'Web page or site' if webpage_site?

            formats
          end

          # Archival and manuscript material
          # LDR/06 = d, f, p, t
          # OR
          # 006/00 = d, f, p,  t
          def archival_manuscript?
            marc_leader_06_match = %w[d f p t].include?(record.leader.byteslice(6))

            marc_006_00_match = record.fields('006').find do |field|
              %w[d f p t].include?(field.value.byteslice(0))
            end

            return true if marc_leader_06_match || marc_006_00_match
          end

          # Audiobook
          # LDR/06 = i AND 008/30-31(any) = a, b, d, e, f, h, k, m, o, p
          # OR
          # 006/00 = i AND 006/13-14(any) = a, b, d, e, f, h, k, m, o, p
          def audiobook?
            marc_leader_06_match = record.leader.byteslice(6) == 'i'
            marc_008_30_31_match = record.fields('008').find do |field|
              (%w[a b d e f h k m o p] & (field.value.byteslice(30..31) || '').split('')).any?
            end

            marc_006_00_13_14_match = record.fields('006').find do |field|
              field.value.byteslice(0) == 'i' &&
                (%w[a b d e f h k m o p] &
                  (field.value.byteslice(13..14) || '').split('')).any?
            end

            return true if (marc_leader_06_match &&
                           marc_008_30_31_match) ||
                           marc_006_00_13_14_match
          end

          # Book
          # LDR/06 = a,t AND LDR/07 = a, c, d, or m AND 008/24-27 (all) != m
          # OR
          # 006/00 = a, t AND 006/07-10 (all) != m
          def book?
            marc_leader_06_match = %w[a t].include?(record.leader.byteslice(6))
            marc_leader_07_match = %w[a c d m].include?(record.leader.byteslice(7))
            marc_008_24_27_match = record.fields('008').find do |field|
              !(field.value.byteslice(24..27) || '').split('').include?('m')
            end

            marc_006_match = record.fields('006').find do |field|
              %w[a t].include?(field.value.byteslice(0)) &&
                !(field.value.byteslice(7..10) || '').split('').include?('m')
            end

            return true if (marc_leader_06_match &&
                           marc_leader_07_match &&
                           marc_008_24_27_match) ||
                           marc_006_match
          end

          # Database
          # LDR/06 = a AND LDR/07 = b, i, or s AND 008/21 = d
          # OR
          # 006/00 = s AND 006/04 = d
          def database?
            marc_leader_06_match = record.leader.byteslice(6) == 'a'
            marc_leader_07_match = %w[b i s].include?(record.leader.byteslice(7))
            marc_008_21_match = record.fields('008').find do |field|
              field.value.byteslice(21) == 'd'
            end

            marc_006_00_04 = record.fields('006').find do |field|
              field.value.byteslice(0) == 's' && field.value.byteslice(4) == 'd'
            end

            return true if (marc_leader_06_match &&
                           marc_leader_07_match &&
                           marc_008_21_match) ||
                           marc_006_00_04
          end

          # Dataset -- Statistical
          # LDR/06 = m AND 008/26 = a
          # OR
          # 006/00 = m AND 006/09 = a
          def dataset_statistical?
            marc_leader_06_m_match = record.leader.byteslice(6) == 'm'
            marc_008_26_match = record.fields('008').find do |field|
              field.value.byteslice(26) == 'a'
            end

            marc_006_match = record.fields('006').find do |field|
              (field.value.byteslice(0) == 'm' && field.value.byteslice(9) == 'a')
            end

            return true if (marc_leader_06_m_match && marc_008_26_match) ||
                           marc_006_match
          end

          # Game
          # LDR/06 = o, r AND 008/33 = g
          # OR
          # LDR/06 = m AND 008/26 = g
          # OR
          # LDR/06 = e, f AND 008/33-34(any) = n
          # OR
          # 006/00 = o, r AND 006/16 = g
          # OR
          # 006/00 = m AND 006/09 = g
          # OR
          # 006/00 = m AND 006/16-17(any) = n
          def game?
            marc_leader_06_o_r_match = %w[o r].include?(record.leader.byteslice(6))
            marc_008_33_g_match = record.fields('008').find do |field|
              field.value.byteslice(33) == 'g'
            end

            marc_leader_06_m_match = record.leader.byteslice(6) == 'm'
            marc_008_26_g_match = record.fields('008').find do |field|
              field.value.byteslice(26) == 'g'
            end

            marc_leader_06_e_f_match = %w[e f].include?(record.leader.byteslice(6))
            marc_008_33_34_n_match = record.fields('008').find do |field|
              (field.value.byteslice(33..34) || '').split('').include?('n')
            end


            marc_006_match = record.fields('006').find do |field|
              (%w[o r].include?(field.value.byteslice(0)) && field.value.byteslice(16) == 'g') ||
                (field.value.byteslice(0) == 'm' && (field.value.byteslice(9) == 'g' ||
                  (field.value.byteslice(16..17) || '').split('').include?('n')))
            end

            return true if (marc_leader_06_o_r_match && marc_008_33_g_match) ||
                           (marc_leader_06_m_match && marc_008_26_g_match) ||
                           (marc_leader_06_e_f_match && marc_008_33_34_n_match) ||
                           marc_006_match
          end

          # Government publication
          # (008/28 = a, c, f, i, l, m, o, s, z AND LDR/06 = a, e, f, g, k, m, o, r, t
          # OR
          # 006/11 = a, c, f, i, l, m, o, s, z AND 006/00 = a, e, f, g, k, m, o, r, t)
          # AND
          # 260/264b does NOT contain 'university' or 'universities press'
          def government_publication?
            gov_pub_rec_types = %w[a e f g k m o r t]
            gov_pub_code_vals = %w[a c f i l m o s z]
            
            marc_leader_06_match = gov_pub_rec_types.include?(record.leader.byteslice(6))
            marc_008_28_match = record.fields('008').find do |field|
              gov_pub_code_vals.include?(field.value.byteslice(28))
            end

            marc_006_00_11_match = record.fields('006').find do |field|
              gov_pub_rec_types.include?(field.value.byteslice(0)) &&
                gov_pub_code_vals.include?(field.value.byteslice(11))
            end

            return true if (marc_leader_06_match && marc_008_28_match) ||
                           marc_006_00_11_match
          end

          def from_university_press?
            # get publisher since we need to exclude university publications
            publishers = []
            record.fields(['260', '264']).each do |field|
              if field.tag == '260'
                publishers << field.find_all { |sf| sf.code == 'b' }
              elsif field.tag == '264'
                publishers << field.find_all { |sf| sf.code == 'b' }
              end
            end
            pubstring = publishers.flatten.to_s.downcase

            if pubstring.include?('university') || pubstring.include?('universities press') ||
               pubstring.include?('school of')
              return true
            else
              return false
            end
          end

          # Image
          # LDR/06 = k
          # OR
          # LDR/06 = m AND 008/26 = c
          # OR
          # LDR/06 = g AND 008/33 = a, c, I, k, l, n, p, s, t
          # OR
          # 006/00 = k
          # OR
          # 006/00 = g AND 006/16 = a, c, I, k, l, n, p, s, t
          def image?
            marc_leader_06_k_match = record.leader.byteslice(6) == 'k'

            marc_leader_06_m_match = record.leader.byteslice(6) == 'm'
            marc_008_26_match = record.fields('008').find do |field|
              field.value.byteslice(26) == 'c'
            end

            marc_leader_06_g_match = record.leader.byteslice(6) == 'g'
            marc_008_33_match = record.fields('008').find do |field|
              %w[a c i k l n p s t].include?(field.value.byteslice(33))
            end

            marc_006_match = record.fields('006').find do |field|
              field.value.byteslice(0) == 'k' ||
                  (field.value.byteslice(0) == '6' &&
                    %w[a c i k l n p s t].include?(field.value.byteslice(16)))
            end

            return true if marc_leader_06_k_match ||
                           (marc_leader_06_m_match && marc_008_26_match) ||
                           (marc_leader_06_g_match && marc_008_33_match) ||
                           marc_006_match
          end

          # Journal, Magazine, or Periodical
          # LDR/06 = a AND LDR/07 = b, i, or s AND 008/21 != d, n, w
          # OR
          # 006/00 = s AND 006/04 != d, n, w
          def journal_magazine_periodical?
            marc_leader_06_match = record.leader.byteslice(6) == 'a'
            marc_leader_07_match = %w[b i s].include?(record.leader.byteslice(7))
            marc_008_21_match = record.fields('008').find do |field|
              !%w[d n w].include?(field.value.byteslice(21))
            end

            marc_006_match = record.fields('006').find do |field|
              field.value.byteslice(0) == 's' &&
                !%w[d n w].include?(field.value.byteslice(4))
            end

            return true if (marc_leader_06_match &&
                           marc_leader_07_match &&
                           marc_008_21_match) ||
                           marc_006_match
          end

          # Kit
          # LDR/06 = o
          # OR
          # 006/00 = o
          def kit?
            marc_leader_06_match = record.leader.byteslice(6) == 'o'

            marc_006_match = record.fields('006').find do |field|
              field.value.byteslice(0) == 'o'
            end

            return true if marc_leader_06_match || marc_006_match
          end

          # Map
          # LDR/06 = e, f
          # OR
          # 006/00 = e, f
          def map?
            marc_leader_06_match = %w[e f].include?(record.leader.byteslice(6))

            marc_006_match = record.fields('006').find do |field|
              %w[e f].include?(field.value.byteslice(0))
            end

            return true if marc_leader_06_match || marc_006_match
          end

          # Music recording
          # LDR/06 = j
          # OR
          # 006/00 = j
          def music_recording?
            marc_leader_06_match = record.leader.byteslice(6) == 'j'

            marc_006_match = record.fields('006').find do |field|
              field.value.byteslice(0) == 'j'
            end

            return true if marc_leader_06_match || marc_006_match
          end

          # Music score
          # LDR/06 = c,d
          # OR
          # 006/00 = c,d
          def music_score?
            marc_leader_06_match = %w[c d].include?(record.leader.byteslice(6))

            marc_006_match = record.fields('006').find do |field|
              %w[c d].include?(field.value.byteslice(0))
            end

            return true if marc_leader_06_match || marc_006_match
          end

          # Newspaper
          # LDR/06 = a AND LDR/07 = b, i, or s AND 008/21 = n
          # OR
          # 006/00 = s AND 006/04 = n
          def newspaper?
            marc_leader_06_match = record.leader.byteslice(6) == 'a'
            marc_leader_07_match = %w[b i s].include?(record.leader.byteslice(7))
            marc_008_21_match = record.fields('008').find do |field|
              field.value.byteslice(21) == 'n'
            end

            marc_006_match = record.fields('006').find do |field|
              field.value.byteslice(0) == 's' &&
                field.value.byteslice(4) == 'n'
            end

            return true if (marc_leader_06_match &&
                           marc_leader_07_match &&
                           marc_008_21_match) ||
                           marc_006_match
          end

          # Non-musical sound recording
          # LDR/06 = i
          # OR
          # 006/00 = i
          def non_musical_sound_recording?
            marc_leader_06_match = record.leader.byteslice(6) == 'i'

            marc_006_match = record.fields('006').find do |field|
              field.value.byteslice(0) == 'i'
            end

            return true if marc_leader_06_match || marc_006_match
          end

          # Object (includes Globes)
          # LDR/06 = r
          # OR
          # LDR/06 = e AND 008/25 = d (globe)
          # OR
          # 006/00 = r
          # OR
          # 006/08 = d (globe)
          # OR
          # 007/00 = d (globe)
          def object?
            marc_leader_06_r_match = record.leader.byteslice(6) == 'r'

            marc_leader_06_e_match = record.leader.byteslice(6) == 'e'
            marc_008_25_match = record.fields('008').find do |field|
              field.value.byteslice(25) == 'd'
            end

            marc_006_match = record.fields('006').find do |field|
              field.value.byteslice(0) == 'r' ||
                field.value.byteslice(8) == 'd'
            end

            marc_007_match = record.fields('007').find do |field|
              field.value.byteslice(0) == 'd'
            end

            return true if marc_leader_06_r_match ||
                           (marc_leader_06_e_match && marc_008_25_match) ||
                           marc_006_match ||
                           marc_007_match
          end

          # Software/multimedia
          # LDR/06 = m AND 008/26 = b, c, g, i, m
          # OR
          # 006/00 = m AND 006/09 = b, c, g, i, m
          def software_multimedia?
            marc_leader_06_match = record.leader.byteslice(6) == 'm'
            marc_008_26_match = record.fields('008').find do |field|
              %w[b c g i m].include?(field.value.byteslice(26))
            end

            marc_006_match = record.fields('006').find do |field|
              field.value.byteslice(0) == 'm' &&
                %w[b c g i m].include?(field.value.byteslice(9))
            end

            return true if (marc_leader_06_match && marc_008_26_match) ||
                           marc_006_match
          end

          # Thesis/Dissertation
          # LDR/06 = a AND 008/24-27(any) = m
          # OR
          # 006/00 = a,s AND 006/07-10(any) = m
          def thesis_dissertation?
            marc_leader_06_match = record.leader.byteslice(6) == 'a'
            marc_008_24_27_match = record.fields('008').find do |field|
              (field.value.byteslice(24..27) || '').split('').include?('m')
            end

            marc_006_match = record.fields('006').find do |field|
              %w[a s].include?(field.value.byteslice(0)) &&
                (field.value.byteslice(7..10) || '').split('').include?('m')
            end

            return true if (marc_leader_06_match && marc_008_24_27_match) ||
                           marc_006_match
          end

          # Video
          # LDR/06 = g AND 008/33 = f, m, v
          # OR
          # 006/00 = g AND 006/16 = f, m, v
          # 007/00 = m, v
          def video?
            marc_leader_06_match = record.leader.byteslice(6) == 'g'
            marc_008_33_match = record.fields('008').find do |field|
              %w[f m v].include?(field.value.byteslice(33))
            end

            marc_006_match = record.fields('006').find do |field|
              field.value.byteslice(0) == 'g' &&
                %w[f m v].include?(field.value.byteslice(16))
            end

            video_007_types = %w[m v]
            marc_007_match = record.fields('007').find do |field|
              video_007_types.include?(field.value.byteslice(0))
            end

            return true if (marc_leader_06_match && marc_008_33_match) ||
                           marc_006_match || marc_007_match
          end

          # Web page or site
          # LDR/06 = a AND LDR/07 = b, i, or s AND 008/21 = w
          # OR
          # 006/00 = a AND 006/04 = w
          def webpage_site?
            marc_leader_06_match = record.leader.byteslice(6) == 'a'
            marc_leader_07_match = %w[b i s].include?(record.leader.byteslice(7))
            marc_008_21_match = record.fields('008').find do |field|
              field.value.byteslice(21) == 'w'
            end

            marc_006_match = record.fields('006').find do |field|
              field.value.byteslice(0) == 'a' &&
                field.value.byteslice(4) == 'w'
            end

            return true if (marc_leader_06_match &&
                           marc_leader_07_match &&
                           marc_008_21_match) ||
                           marc_006_match
          end
        end
      end
    end
  end
end
