module MarcToArgot
  # Traject indexer subclasses configured to load
  # the appropriate collection-specific macros and
  # methods.
  module Indexers
    # Indexer configured for UNC general collection.
    class UNC < Traject::Indexer
      include MarcToArgot::Macros::UNC
    end
    # Indexer configured for Duke's general collection.
    class Duke < Traject::Indexer
      include MarcToArgot::Macros::Duke
    end
    # Indexer configured for NCCU's general collection.
    class NCCU < Traject::Indexer
      include MarcToArgot::Macros::NCCU
    end

    # Indexer configured for NCSU's general collection
    class NCSU < Traject::Indexer
      include MarcToArgot::Macros::NCSU
    end

    VALUES = { duke: Duke,
               nccu: NCCU,
               ncsu: NCSU,
               unc: UNC
    }.freeze

    # Loads the appropriate indexer for the collection
    def self.find(collection = :argot)
      VALUES.fetch(collection.to_sym, Traject::Indexer)
    end
  end
end
