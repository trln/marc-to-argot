module MarcToArgot
  module Macros
    module NCSU
      # Map resource types for NCSU.
      module ResourceType
        include MarcToArgot::Macros::Shared::ResourceType

        # Gets resource type based on a mix of fixed fields,
        # item types, and itemcat2 (Sirsi)
        def self.classify(rec, items)
          cl = ResourceTypeClassifier.new(rec)
          itemcat2s = items.map { |x| x['item_cat_2'] }.compact
          item_types = items.map { |i| i['type'] }.compact
          types = []
          types << 'Book' if cl.book?
          unless cl.from_university_press?
            types << 'Government publication' if cl.government_publication?
          end
          types << 'Journal, Magazine, or Periodical' if cl.journal_magazine_periodical?
          types << 'Video' if cl.video?
          types << 'Dataset -- Statistical' if item_types.include?('DATASET')
          types << 'Music recording' if cl.music_recording?
          types << 'Music score' if cl.music_score?
          types << 'Map' unless (item_types & %w[MAP MAP-CIRC]).empty?
          types << 'Image' if cl.image?
          # 'Software/multimedia' NOT MAPPED
          types << 'Archival and manuscript material' if item_types.include?('MANUSCRIPT')
          types << 'Newspaper' if cl.newspaper?
          types << 'Web page or site' if item_types.include?('WEBSITE')
          types << 'Thesis/Dissertation' if item_types.include?('THESIS')
          if item_types.include?('AUDIOBOOK')
            types << 'Audiobook'
          elsif cl.non_musical_sound_recording?
            types << 'Non-musical sound recording'
          end
          types << 'Database' if item_types.include?('DATABASE')
          types << 'Object' if cl.object?
          types << 'Game' if cl.game?
          types << 'Kit' if cl.kit?
          types
        end
      end
    end
  end
end
